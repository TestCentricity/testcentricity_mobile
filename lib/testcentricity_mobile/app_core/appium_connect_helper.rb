require 'appium_lib'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'


module TestCentricity
  module AppiumConnect
    attr_accessor :driver
    attr_accessor :running
    attr_accessor :endpoint
    attr_accessor :capabilities
    attr_accessor :global_scope

    # Create a new driver instance with capabilities specified in the options parameter, or via Environment Variables.
    # Refer to the `Connecting to a Mobile Simulator or Device` section of the ruby docs for this gem.
    #
    def self.initialize_appium(options = nil)
      @endpoint = nil
      @capabilities = nil
      @running = false
      @global_scope = false
      Environ.driver_name = nil
      Environ.device_orientation = nil
      Environ.platform = :mobile
      Environ.device = :simulator

      if options.is_a?(Hash)
        @endpoint = options[:endpoint] if options.key?(:endpoint)
        @capabilities = options[:capabilities] if options.key?(:capabilities)
        @global_scope = options[:global_driver] if options.key?(:global_driver)
        Environ.driver = options[:driver] if options.key?(:driver)
        Environ.driver_name = options[:driver_name] if options.key?(:driver_name)
        Environ.device_type = options[:device_type] if options.key?(:device_type)
      end
      if @capabilities.nil?
        Environ.driver = ENV['DRIVER'].downcase.to_sym if ENV['DRIVER']
        Environ.device_type = ENV['DEVICE_TYPE'] if ENV['DEVICE_TYPE']
        Environ.device_orientation = ENV['ORIENTATION'] if ENV['ORIENTATION']
      else
        raise ':browserName is specified in capabilities' if @capabilities[:browserName]
      end

      raise 'You must specify a driver' if Environ.driver.nil?
      raise 'You must specify a device type - :phone or :tablet' if Environ.device_type.nil?

      driver_caps = case Environ.driver
                    when :appium
                      appium_local_capabilities
                    when :custom
                      raise 'User-defined cloud driver requires that you define options' if options.nil?
                      custom_capabilities
                    when :browserstack
                      browserstack_capabilities
                    when :testingbot
                      testingbot_capabilities
                      # :nocov:
                    when :saucelabs
                      sauce_capabilities
                    else
                      raise "#{Environ.driver} is not a supported driver"
                      # :nocov:
                    end
      driver_opts = {
        caps: driver_caps,
        appium_lib: { server_url: @endpoint }
      }
      @driver = Appium::Driver.new(driver_opts, global_driver = @global_scope)
      @driver.start_driver
      Environ.appium_driver = @driver
      @running = true
      Appium.promote_appium_methods(TestCentricity::ScreenObject, driver = @driver)
      Appium.promote_appium_methods(TestCentricity::ScreenSection, driver = @driver)
      Appium.promote_appium_methods(TestCentricity::AppElements::AppUIElement, driver = @driver)

      Environ.screen_size = window_size
      unless Environ.driver_name
        Environ.driver_name = "#{Environ.driver}_#{Environ.device_os}_#{Environ.device_type}".downcase.to_sym
      end
      Environ.session_state = :running
    end

    # Quit the running driver instance. Sets Environ.session_state to :quit.
    #
    def self.quit_driver
      if @running
        driver.driver_quit
        @running = false
      end
      Environ.session_state = :quit
    end

    # Return a reference to last created Appium driver
    #
    def self.driver
      @driver
    end

    # Save a screenshot in .png format to the specified file path.
    #
    # @param png_save_path [String] path to save the screenshot
    # @example
    #   AppiumConnect.take_screenshot('reports/screenshots/login_screen.png')
    #
    def self.take_screenshot(png_save_path)
      FileUtils.mkdir_p(File.dirname(png_save_path))
      driver.driver.save_screenshot(png_save_path)
    end

    # Install app on device. If bundle_id is not specified, then bundle id will be retrieved from Environ.current.ios_bundle_id
    # or Environ.current.android_app_id dependent on which platform is being tested.
    #
    # @param bundle_id [String] OPTIONAL bundle id of app
    # @example
    #   AppiumConnect.install_app('com.saucelabs.mydemoapp.rn')
    #
    def self.install_app(app_path)
      driver.install_app(app_path)
    end

    # Remove app from device. If bundle_id is not specified, then bundle id will be retrieved from Environ.current.ios_bundle_id
    # or Environ.current.android_app_id dependent on which platform is being tested.
    #
    # @param bundle_id [String] OPTIONAL bundle id of app
    # @example
    #   AppiumConnect.remove_app('com.saucelabs.mydemoapp.rn')
    #
    def self.remove_app(bundle_id = nil)
      driver.remove_app(get_app_id(bundle_id))
    end

    # Is the app installed? If bundle_id is not specified, then bundle id will be retrieved from Environ.current.ios_bundle_id
    # or Environ.current.android_app_id dependent on which platform is being tested.
    #
    # @param bundle_id [String] OPTIONAL bundle id of app
    # @return [Boolean] TRUE if app is installed
    # @example
    #   AppiumConnect.app_installed?('com.saucelabs.mydemoapp.rn')
    #
    def self.app_installed?(bundle_id = nil)
      driver.app_installed?(get_app_id(bundle_id))
    end

    # Backgrounds the app for a specified number of seconds.
    #
    # @param duration [Integer] number of seconds to background the app for
    # @example
    #   AppiumConnect.background_app(20)
    #
    def self.background_app(duration = 0)
      driver.background_app(duration)
    end

    # Launch the app. If bundle_id is not specified, then bundle id will be retrieved from Environ.current.ios_bundle_id
    # or Environ.current.android_app_id dependent on which platform is being tested.
    #
    # @param bundle_id [String] OPTIONAL bundle id of app
    # @example
    #   AppiumConnect.activate_app('com.saucelabs.mydemoapp.rn')
    #
    def self.activate_app(bundle_id = nil)
      driver.activate_app(get_app_id(bundle_id))
      if Environ.is_android?
        sleep(1.5) if app_state == :running_in_foreground
      end
      Environ.new_app_session
    end

    # Get status of app. If bundle_id is not specified, then bundle id will be retrieved from Environ.current.ios_bundle_id
    # or Environ.current.android_app_id dependent on which platform is being tested. Returns the following statuses:
    #    :not_installed - The current application state cannot be determined/is unknown
    #    :not_running - The application is not running
    #    :running_in_background_suspended - The application is running in the background and is suspended
    #    :running_in_background - The application is running in the background and is not suspended
    #    :running_in_foreground - The application is running in the foreground
    #
    # @param bundle_id [String] OPTIONAL bundle id of app
    # @return [Symbol] status of app
    # @example
    #   AppiumConnect.app_state('com.saucelabs.mydemoapp.rn')
    #
    def self.app_state(bundle_id = nil)
      driver.app_state(get_app_id(bundle_id))
    end

    # Terminate the app. If bundle_id is not specified, then bundle id will be retrieved from Environ.current.ios_bundle_id
    # or Environ.current.android_app_id dependent on which platform is being tested.
    #
    # @param bundle_id [String] OPTIONAL bundle id of app
    # @example
    #   AppiumConnect.terminate_app('com.saucelabs.mydemoapp.rn')
    #
    def self.terminate_app(bundle_id = nil)
      driver.terminate_app(get_app_id(bundle_id))
    end

    # Set the amount of time the driver should wait when searching for elements.
    #
    # @param timeout [Integer] number of seconds to wait
    #
    def self.implicit_wait(timeout)
      driver.manage.timeouts.implicit_wait = timeout
    end

    # Hide the onscreen keyboard
    #
    def self.hide_keyboard
      driver.hide_keyboard
    end

    # Is onscreen keyboard displayed?
    #
    # @return [Boolean] TRUE if keyboard is shown. Return false if keyboard is hidden.
    #
    def self.keyboard_shown?
      @driver.execute_script('mobile: isKeyboardShown')
    end

    # Get the current screen orientation
    #
    # @return [Symbol] :landscape or :portrait
    #
    def self.orientation
      driver.driver.orientation
    end

    # Change the screen orientation
    #
    # @param orientation [Symbol or String] :landscape or :portrait
    #
    def self.rotation(orientation)
      orientation.downcase.to_sym if orientation.is_a?(String)
      driver.driver.rotation = orientation
    end

    # Get the device's window size.
    #
    # @return [Array] window size as [width, height]
    #
    def self.window_size
      size = driver.window_size
      [size.width, size.height]
    end

    # Get the device's window rectangle.
    #
    # @return (Selenium::WebDriver::Rectangle)
    #
    def self.window_rect
      driver.window_rect
    end

    def self.geolocation
      driver.driver.location
    end

    def self.set_geolocation(location_data)
      driver.set_location(location_data)
    end

    def self.current_context
      driver.current_context
    end

    def self.set_context(context)
      driver.set_context(context)
    end

    def self.available_contexts
      driver.available_contexts
    end

    def self.is_webview?
      driver.current_context.start_with?('WEBVIEW')
    end

    def self.is_native_app?
      driver.current_context.start_with?('NATIVE_APP')
    end

    def self.webview_context
      contexts = driver.available_contexts
      puts "Contexts = #{contexts}" if ENV['DEBUG']
      set_context(contexts.last)
      puts "Current context = #{driver.current_context}" if ENV['DEBUG']
    end

    def self.is_biometric_enrolled?
      if Environ.is_ios?
        @driver.execute_script('mobile: isBiometricEnrolled')
      else
        puts 'biometric_enrollment is not supported for Android'
      end
    end

    def self.set_biometric_enrollment(state)
      if Environ.is_ios?
        @driver.execute_script('mobile: enrollBiometric', { isEnabled: state })
      else
        puts 'biometric_enrollment is not supported for Android'
      end
    end

    def self.biometric_match(type, match)
      if Environ.is_ios?
        @driver.execute_script('mobile: sendBiometricMatch', { type: type, match: match })
      else
        raise 'biometric_match is not supported for Android'
      end
    end

    # :nocov:
    def self.upload_app(service)
      # determine app custom test id (if specified)
      custom_id = if ENV['APP_ID']
                    ENV['APP_ID']
                  else
                    Environ.is_android? ? Environ.current.android_test_id : Environ.current.ios_test_id
                  end
      # determine endpoint url, user id, and auth key for specified cloud service provider
      case service
      when :browserstack
        url = 'https://api-cloud.browserstack.com/app-automate/upload'
        user_id = ENV['BS_USERNAME']
        auth_key = ENV['BS_AUTHKEY']
      when :testingbot
        url = 'https://api.testingbot.com/v1/storage'
        url = "#{url}/#{custom_id}" unless custom_id.nil?
        user_id = ENV['TB_USERNAME']
        auth_key = ENV['TB_AUTHKEY']
      else
        raise "#{service} is not supported"
      end
      # determine file path of app to be uploaded to cloud service
      file_path = if Environ.is_android?
                    Environ.current.android_apk_path
                  elsif Environ.is_ios?
                    Environ.is_device? ? Environ.current.ios_ipa_path : Environ.current.ios_app_path
                  end

      request = Net::HTTP::Post.new(url)
      boundary = "WebAppBoundary"
      post_body = []
      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{file_path}\"\r\n"
      post_body << "\r\n"
      post_body << File.open(file_path) {|io| io.read}
      # add custom id form data to post body if a custom test id has been provided
      if !custom_id.nil? && service == :browserstack
        post_body << "\r\n--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"custom_id\"\r\n"
        post_body << "\r\n"
        post_body << "#{custom_id}"
      end
      post_body << "\r\n--#{boundary}--\r\n"
      request.body = post_body.join
      request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
      request.basic_auth(user_id, auth_key)
      # send the request to upload to cloud service provider
      uri = URI.parse(url)
      conn = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        conn.use_ssl = true
        conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = conn.request(request)
      result = JSON.parse(response.body)
      if response.code.to_i > 202
        raise "An error has occurred while attempting to upload #{file_path} to the #{service} service\n#{result}"
      else
        puts "Successfully uploaded #{file_path} to the #{service} service\n#{result}"
      end
     end
    # :nocov:

    private

    def self.get_app_id(bundle_id = nil)
      return bundle_id unless bundle_id.nil?

      if Environ.is_ios?
        Environ.current.ios_bundle_id
      elsif Environ.is_android?
        Environ.current.android_app_id
      else
        nil
      end
    end

    def self.appium_local_capabilities
      # specify endpoint url
      if @endpoint.nil?
        @endpoint = if ENV['APPIUM_SERVER_VERSION'] && ENV['APPIUM_SERVER_VERSION'].to_i == 1
                      'http://127.0.0.1:4723/wd/hub'
                    else
                      'http://127.0.0.1:4723'
                    end
      end
      # define local Appium capabilities
      if @capabilities.nil?
        Environ.device_name = ENV['APP_DEVICE']
        Environ.device_os = ENV['APP_PLATFORM_NAME']
        Environ.device_os_version = ENV['APP_VERSION']
        Environ.device = ENV['UDID'] ? :device : :simulator

        caps = {
          platformName: ENV['APP_PLATFORM_NAME'],
          'appium:platformVersion': ENV['APP_VERSION'],
          'appium:deviceName': ENV['APP_DEVICE'],
          'appium:automationName': ENV['AUTOMATION_ENGINE']
        }
        caps[:'appium:avd'] = ENV['APP_DEVICE'] if ENV['APP_PLATFORM_NAME'].downcase.to_sym == :android
        caps[:'appium:orientation'] = ENV['ORIENTATION'].upcase if ENV['ORIENTATION']
        if ENV['LOCALE'] && ENV['LANGUAGE']
          caps[:'appium:language'] = ENV['LANGUAGE']
          caps[:'appium:locale'] = if Environ.is_android?
                            locale = ENV['LOCALE'].gsub('-', '_')
                            locale.split('_')[1]
                          else
                            ENV['LOCALE'].gsub('-', '_')
                          end
        end
        caps[:'appium:newCommandTimeout'] = ENV['NEW_COMMAND_TIMEOUT'] if ENV['NEW_COMMAND_TIMEOUT']
        caps[:'appium:noReset'] = ENV['APP_NO_RESET'] if ENV['APP_NO_RESET']
        caps[:'appium:fullReset'] = ENV['APP_FULL_RESET'] if ENV['APP_FULL_RESET']
        caps[:'appium:autoLaunch'] = ENV['AUTO_LAUNCH'] if ENV['AUTO_LAUNCH']
        caps[:'appium:webkitDebugProxyPort'] = ENV['WEBKIT_DEBUG_PROXY_PORT'] if ENV['WEBKIT_DEBUG_PROXY_PORT']
        caps[:'appium:webDriverAgentUrl'] = ENV['WEBDRIVER_AGENT_URL'] if ENV['WEBDRIVER_AGENT_URL']
        caps[:'appium:wdaLocalPort'] = ENV['WDA_LOCAL_PORT'] if ENV['WDA_LOCAL_PORT']
        caps[:'appium:usePrebuiltWDA'] = ENV['USE_PREBUILT_WDA'] if ENV['USE_PREBUILT_WDA']
        caps[:'appium:useNewWDA'] = ENV['USE_NEW_WDA'] if ENV['USE_NEW_WDA']
        caps[:'appium:autoWebview'] = ENV['AUTO_WEBVIEW'] if ENV['AUTO_WEBVIEW']
        caps[:'appium:chromedriverExecutable'] = ENV['CHROMEDRIVER_EXECUTABLE'] if ENV['CHROMEDRIVER_EXECUTABLE']
        caps[:'appium:autoWebviewTimeout'] = ENV['AUTO_WEBVIEW_TIMEOUT'] if ENV['AUTO_WEBVIEW_TIMEOUT']
        caps[:'appium:udid'] = ENV['UDID'] if ENV['UDID']
        caps[:'appium:xcodeOrgId'] = ENV['TEAM_ID'] if ENV['TEAM_ID']
        caps[:'appium:xcodeSigningId'] = ENV['TEAM_NAME'] if ENV['TEAM_NAME']
        caps[:'appium:appActivity'] = ENV['APP_ACTIVITY'] if ENV['APP_ACTIVITY']
        caps[:'appium:appPackage'] = ENV['APP_PACKAGE'] if ENV['APP_PACKAGE']
        caps[:'appium:forceSimulatorSoftwareKeyboardPresence'] = ENV['SHOW_SIM_KEYBOARD'] if ENV['SHOW_SIM_KEYBOARD']
        if Environ.is_ios?
          caps[:'appium:webviewConnectTimeout'] = 90000
          caps[:'appium:maxTypingFrequency'] = 15
          caps[:'appium:respectSystemAlerts'] = true
        end

        if ENV['BUNDLE_ID']
          caps[:'appium:bundleId'] = ENV['BUNDLE_ID']
        else
          app_id = get_app_id
          caps[:'appium:bundleId'] = app_id unless app_id.nil?
        end

        caps[:'appium:app'] = if ENV['APP']
                       ENV['APP']
                     else
                       if Environ.is_android?
                         Environ.current.android_apk_path
                       elsif Environ.is_ios?
                         Environ.is_device? ?
                           Environ.current.ios_ipa_path :
                           Environ.current.ios_app_path
                       end
        end
        caps
      else
        Environ.device_os = @capabilities[:platformName]
        Environ.device_name = @capabilities[:'appium:deviceName']
        Environ.device_os_version = @capabilities[:'appium:platformVersion']
        Environ.device_orientation = @capabilities[:'appium:orientation']
        Environ.device = @capabilities[:'appium:udid'] ? :device : :simulator
        @capabilities
      end
    end

    def self.custom_capabilities
      raise 'User-defined cloud driver requires that you provide capabilities' if @capabilities.nil?
      raise 'User-defined cloud driver requires that you provide an endpoint' if @endpoint.nil?

      Environ.device_os = @capabilities[:platformName]
      Environ.device_name = @capabilities[:'appium:deviceName']
      Environ.device_os_version = @capabilities[:'appium:platformVersion']
      @capabilities
    end

    def self.browserstack_capabilities
      # specify endpoint url
      @endpoint = "https://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub-cloud.browserstack.com/wd/hub" if @endpoint.nil?
      # define BrowserStack options
      options = if @capabilities.nil?
                  Environ.device_name = ENV['BS_DEVICE']
                  Environ.device_os = ENV['BS_OS']
                  Environ.device_os_version = ENV['BS_OS_VERSION']
                  # define the required set of BrowserStack options
                  bs_options = {
                    userName: ENV['BS_USERNAME'],
                    accessKey: ENV['BS_AUTHKEY'],
                    sessionName: test_context_message
                  }
                  # define the optional BrowserStack options
                  bs_options[:projectName] = ENV['AUTOMATE_PROJECT'] if ENV['AUTOMATE_PROJECT']
                  bs_options[:buildName] = ENV['AUTOMATE_BUILD'] if ENV['AUTOMATE_BUILD']
                  bs_options[:geoLocation] = ENV['IP_GEOLOCATION'] if ENV['IP_GEOLOCATION']
                  bs_options[:timezone] = ENV['TIME_ZONE'] if ENV['TIME_ZONE']
                  bs_options[:video] = ENV['RECORD_VIDEO'] if ENV['RECORD_VIDEO']
                  bs_options[:debug] = ENV['SCREENSHOTS'] if ENV['SCREENSHOTS']
                  bs_options[:local] = ENV['TUNNELING'] if ENV['TUNNELING']
                  bs_options[:deviceOrientation] = ENV['ORIENTATION'] if ENV['ORIENTATION']
                  bs_options[:appiumLogs] = ENV['APPIUM_LOGS'] if ENV['APPIUM_LOGS']
                  bs_options[:networkLogs] = ENV['NETWORK_LOGS'] if ENV['NETWORK_LOGS']
                  bs_options[:deviceLogs] = ENV['DEVICE_LOGS'] if ENV['DEVICE_LOGS']
                  bs_options[:networkProfile] = ENV['NETWORK_PROFILE'] if ENV['NETWORK_PROFILE']
                  bs_options[:idleTimeout] = ENV['IDLE_TIMEOUT'] if ENV['IDLE_TIMEOUT']
                  bs_options[:resignApp] = ENV['RESIGN_APP'] if ENV['RESIGN_APP']
                  bs_options[:gpsLocation] = ENV['GPS_LOCATION'] if ENV['GPS_LOCATION']
                  bs_options[:acceptInsecureCerts] = ENV['ACCEPT_INSECURE_CERTS'] if ENV['ACCEPT_INSECURE_CERTS']
                  bs_options[:disableAnimations] = ENV['DISABLE_ANIMATION'] if ENV['DISABLE_ANIMATION']
                  bs_options[:appiumVersion] = ENV['APPIUM_VERSION'] ? ENV['APPIUM_VERSION'] : '2.6.0'

                  capabilities = {
                    platformName: ENV['BS_OS'],
                    'appium:platformVersion': ENV['BS_OS_VERSION'],
                    'appium:deviceName': ENV['BS_DEVICE'],
                    'appium:automationName': ENV['AUTOMATION_ENGINE'],
                    'appium:app': ENV['APP'],
                    'bstack:options': bs_options
                  }
                  capabilities[:language] = ENV['LANGUAGE'] if ENV['LANGUAGE']
                  capabilities[:locale] = ENV['LOCALE'] if ENV['LOCALE']
                  capabilities
                else
                  Environ.device_os = @capabilities[:platformName]
                  Environ.device_name = @capabilities[:'appium:deviceName']
                  Environ.device_os_version = @capabilities[:'appium:platformVersion']
                  @capabilities
                end
      # BrowserStack uses only real devices
      Environ.device = :device
      upload_app(:browserstack) if ENV['UPLOAD_APP']
      options
    end

    # :nocov:
    def self.testingbot_capabilities
      Environ.device = :simulator
      # specify endpoint url
      @endpoint = "https://#{ENV['TB_USERNAME']}:#{ENV['TB_AUTHKEY']}@hub.testingbot.com/wd/hub" if @endpoint.nil?
      # define TestingBot options
      options = if @capabilities.nil?
                  Environ.device_name = ENV['TB_DEVICE']
                  Environ.device_os = ENV['TB_OS']
                  Environ.device_os_version = ENV['TB_OS_VERSION']
                  Environ.device = :device if ENV['REAL_DEVICE'] == 'true'
                  # define the required set of TestingBot options
                  tb_options = { build: test_context_message }
                  # define the optional TestingBot options
                  tb_options[:name] = ENV['AUTOMATE_PROJECT'] if ENV['AUTOMATE_PROJECT']
                  tb_options[:timeZone] = ENV['TIME_ZONE'] if ENV['TIME_ZONE']
                  tb_options['testingbot.geoCountryCode'] = ENV['IP_GEOLOCATION'] if ENV['IP_GEOLOCATION']
                  tb_options[:screenrecorder] = ENV['RECORD_VIDEO'] if ENV['RECORD_VIDEO']
                  tb_options[:screenshot] = ENV['SCREENSHOTS'] if ENV['SCREENSHOTS']
                  tb_options[:appiumVersion] = ENV['APPIUM_VERSION'] ? ENV['APPIUM_VERSION'] : '2.10.3'

                  capabilities = {
                    platformName: ENV['TB_OS'],
                    'appium:platformVersion': ENV['TB_OS_VERSION'],
                    'appium:deviceName': ENV['TB_DEVICE'],
                    'appium:automationName': ENV['AUTOMATION_ENGINE'],
                    'appium:app': ENV['APP'],
                    'tb:options': tb_options
                  }
                  capabilities[:'appium:realDevice'] = ENV['REAL_DEVICE'] if ENV['REAL_DEVICE']
                  capabilities
                else
                  Environ.device_os = @capabilities[:platformName]
                  Environ.device_name = @capabilities[:'appium:deviceName']
                  Environ.device_os_version = @capabilities[:'appium:platformVersion']
                  if @capabilities.key?(:'appium:realDevice') && @capabilities[:'appium:realDevice'] == true
                    Environ.device = :device
                  end
                  @capabilities
                end

      upload_app(:testingbot) if ENV['UPLOAD_APP']
      options
    end

    def self.sauce_capabilities
      # specify endpoint url
      if @endpoint.nil?
        @endpoint = "https://#{ENV['SL_USERNAME']}:#{ENV['SL_AUTHKEY']}@ondemand.#{ENV['SL_DATA_CENTER']}.saucelabs.com:443/wd/hub"
      end
      # define SauceLabs options
      options = if @capabilities.nil?
                  Environ.device_name = ENV['SL_DEVICE']
                  Environ.device_os = ENV['SL_OS']
                  Environ.device_os_version = ENV['SL_OS_VERSION']
                  # define the required set of SauceLabs options
                  sl_options = { build: test_context_message }
                  # define the optional SauceLabs options
                  sl_options[:name] = ENV['AUTOMATE_PROJECT'] if ENV['AUTOMATE_PROJECT']
                  sl_options[:deviceOrientation] = ENV['ORIENTATION'].upcase if ENV['ORIENTATION']
                  sl_options[:recordVideo] = ENV['RECORD_VIDEO'] if ENV['RECORD_VIDEO']
                  sl_options[:recordScreenshots] = ENV['SCREENSHOTS'] if ENV['SCREENSHOTS']
                  sl_options[:appiumVersion] = ENV['APPIUM_VERSION'] ? ENV['APPIUM_VERSION'] : '2.1.3'
                  capabilities = {
                    platformName: ENV['SL_OS'],
                    'appium:platformVersion': ENV['SL_OS_VERSION'],
                    'appium:deviceName': ENV['SL_DEVICE'],
                    'appium:automationName': ENV['AUTOMATION_ENGINE'],
                    'appium:app': ENV['APP'],
                    'sauce:options': sl_options
                  }
                  capabilities
                else
                  Environ.device_os = @capabilities[:platformName]
                  Environ.device_name = @capabilities[:'appium:deviceName']
                  Environ.device_os_version = @capabilities[:'appium:platformVersion']
                  @capabilities
                end
      options
    end

    def self.test_context_message
      context_message = if ENV['TEST_CONTEXT']
                          "#{Environ.test_environment.to_s.upcase} - #{ENV['TEST_CONTEXT']}"
                        else
                          Environ.test_environment.to_s.upcase
                        end
      if ENV['PARALLEL']
        thread_num = ENV['TEST_ENV_NUMBER']
        thread_num = 1 if thread_num.blank?
        context_message = "#{context_message} - Thread ##{thread_num}"
      end
      context_message
    end
    # :nocov:
  end
end
