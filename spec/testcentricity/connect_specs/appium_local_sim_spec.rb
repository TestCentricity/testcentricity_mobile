# frozen_string_literal: true

describe TestCentricity::AppiumConnect, required: true do
  before(:context) do
    # instantiate React Native Demo test environment
    @environs ||= EnvironData
    @environs.find_environ('RN_DEMO', :yaml)
    ENV['DRIVER'] = 'appium'
    ENV['DEVICE_TYPE'] = 'phone'
    ENV['LOCALE'] = 'en-US'
    ENV['LANGUAGE'] = 'en'
    # start Appium server
    $server = TestCentricity::AppiumServer.new
    $server.start
  end

  describe 'Connect to locally hosted mobile device simulator using W3C desired_capabilities hash' do
    context 'Driver exceptions' do
      it 'raises exception when browserName is defined' do
        options = {
          driver: :appium,
          device_type: :phone,
          capabilities: {
            platformName: :ios,
            browserName: :safari,
            'appium:platformVersion': '15.4',
            'appium:deviceName': 'iPhone 13 Pro Max',
            'appium:automationName': 'XCUITest',
            'appium:app': Environ.current.ios_app_path
          }
        }
        expect { AppiumConnect.initialize_appium(options) }.to raise_error(':browserName is specified in capabilities')
      end

      it 'raises exception when invalid driver defined' do
        options = {
          driver: :invalid_driver,
          device_type: :phone,
          capabilities: {
            platformName: :ios,
            'appium:platformVersion': '15.4',
            'appium:deviceName': 'iPhone 13 Pro Max',
            'appium:automationName': 'XCUITest',
            'appium:app': Environ.current.ios_app_path
          }
        }
        expect { AppiumConnect.initialize_appium(options) }.to raise_error('invalid_driver is not a supported driver')
      end

      it 'raises exception when no device type is defined' do
        options = {
          driver: :appium,
          capabilities: {
            platformName: :ios,
            'appium:platformVersion': '15.4',
            'appium:deviceName': 'iPhone 13 Pro Max',
            'appium:automationName': 'XCUITest',
            'appium:app': Environ.current.ios_app_path
          }
        }
        expect { AppiumConnect.initialize_appium(options) }.to raise_error('You must specify a device type - :phone or :tablet')
      end

      it 'raises exception when no driver defined' do
        options = {
          device_type: :phone,
          capabilities: {
            platformName: :ios,
            'appium:platformVersion': '15.4',
            'appium:deviceName': 'iPhone 13 Pro Max',
            'appium:automationName': 'XCUITest',
            'appium:app': Environ.current.ios_app_path
          }
        }
        expect { AppiumConnect.initialize_appium(options) }.to raise_error('You must specify a driver')
      end
    end

    context 'Mobile iOS device simulator' do
      let(:ios_caps) {
        {
          driver: :appium,
          device_type: :phone,
          endpoint: 'http://127.0.0.1:4723/wd/hub',
          capabilities: {
            platformName: :ios,
            'appium:platformVersion': '15.4',
            'appium:deviceName': 'iPhone 13 Pro Max',
            'appium:automationName': 'XCUITest',
            'appium:app': Environ.current.ios_app_path,
            'appium:language': ENV['LANGUAGE'],
            'appium:locale': ENV['LOCALE']
          }
        }
      }

      it 'connects to iOS iPhone Simulator using desired_capabilities hash' do
        AppiumConnect.initialize_appium(ios_caps)
        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :ios,
          os_version = '15.4',
          dev_name = 'iPhone 13 Pro Max'
        )
        expect($driver).to eq(nil)
      end

      it 'connects to iOS iPhone Simulator with a user-defined driver name' do
        options = {
          driver: :appium,
          device_type: :phone,
          driver_name: :my_custom_iphone_driver,
          capabilities: {
            platformName: :ios,
            'appium:platformVersion': '15.4',
            'appium:deviceName': 'iPhone 13 Pro Max',
            'appium:automationName': 'XCUITest',
            'appium:app': Environ.current.ios_app_path
          }
        }
        AppiumConnect.initialize_appium(options)
        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :ios,
          os_version = '15.4',
          dev_name = 'iPhone 13 Pro Max',
          driver_name = :my_custom_iphone_driver
        )
      end

      it 'verifies iOS app is installed and running in foreground' do
        AppiumConnect.initialize_appium(ios_caps)
        expect(AppiumConnect.app_installed?).to eq(true)
        expect(AppiumConnect.app_state).to eq(:running_in_foreground)
        expect(AppiumConnect.orientation).to eq(:portrait)
        expect(AppiumConnect.window_size).to eq([428, 926])
        expect(AppiumConnect.keyboard_shown?).to eq(false)
        expect(AppiumConnect.current_context).to eq('NATIVE_APP')
        expect(AppiumConnect.available_contexts).to eq(['NATIVE_APP'])
        expect(AppiumConnect.is_webview?).to eq(false)
        expect(AppiumConnect.is_native_app?).to eq(true)
        rect = AppiumConnect.window_rect
        expect(rect.x).to eq(0)
        expect(rect.y).to eq(0)
        expect(rect.width).to eq(428)
        expect(rect.height).to eq(926)
      end

      it 'verifies iOS app is terminated' do
        AppiumConnect.initialize_appium(ios_caps)
        AppiumConnect.terminate_app
        expect(AppiumConnect.app_state).to eq(:not_running)
      end

      it 'verifies iOS app can be suspended and activated' do
        AppiumConnect.initialize_appium(ios_caps)
        # verify app suspension
        Environ.appium_driver.execute_script('mobile: pressButton', { name: 'home' })
        sleep(4)
        expect(AppiumConnect.app_state).to eq(:running_in_background_suspended)
        # verify app activation
        AppiumConnect.activate_app
        expect(AppiumConnect.app_state).to eq(:running_in_foreground)
      end

      it 'verifies iOS app can be removed and re-installed' do
        AppiumConnect.initialize_appium(ios_caps)
        # verify app removal
        AppiumConnect.remove_app
        expect(AppiumConnect.app_installed?).to eq(false)
        expect(AppiumConnect.app_state).to eq(:not_running)
        # verify app installation
        AppiumConnect.install_app(Environ.current.ios_app_path)
        expect(AppiumConnect.app_installed?).to eq(true)
        expect(AppiumConnect.app_state).to eq(:not_running)
      end

      it 'connects to iOS iPhone Simulator with global driver scope' do
        options = {
          driver: :appium,
          device_type: :phone,
          global_driver: true,
          capabilities: {
            platformName: :ios,
            'appium:platformVersion': '15.4',
            'appium:deviceName': 'iPhone 13 Pro Max',
            'appium:automationName': 'XCUITest',
            'appium:app': Environ.current.ios_app_path
          }
        }
        AppiumConnect.initialize_appium(options)
        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :ios,
          os_version = '15.4',
          dev_name = 'iPhone 13 Pro Max'
        )
        expect($driver).to eq(Environ.appium_driver)
      end
    end

    context 'Mobile Android device simulator' do
      let(:android_caps) {
        {
          driver: :appium,
          device_type: :phone,
          endpoint: 'http://127.0.0.1:4723/wd/hub',
          capabilities: {
            platformName: :android,
            'appium:platformVersion': '12.0',
            'appium:deviceName': 'Pixel_5_API_31',
            'appium:automationName': 'UiAutomator2',
            'appium:avd': 'Pixel_5_API_31',
            'appium:app': Environ.current.android_apk_path
          }
        }
      }

      it 'connects to Android Simulator using desired_capabilities hash' do
        AppiumConnect.initialize_appium(android_caps)
        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :android,
          os_version = '12.0',
          dev_name = 'Pixel_5_API_31'
        )
        expect($driver).to eq(nil)
      end

      it 'connects to Android Simulator with a user-defined driver name' do
        options = {
          driver: :appium,
          device_type: :phone,
          driver_name: :my_custom_android_driver,
          capabilities: {
            platformName: :android,
            'appium:platformVersion': '12.0',
            'appium:deviceName': 'Pixel_5_API_31',
            'appium:automationName': 'UiAutomator2',
            'appium:avd': 'Pixel_5_API_31',
            'appium:app': Environ.current.android_apk_path
          }
        }
        AppiumConnect.initialize_appium(options)
        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :android,
          os_version = '12.0',
          dev_name = 'Pixel_5_API_31',
          driver_name = :my_custom_android_driver
        )
      end

      it 'verifies Android app is installed and running in foreground' do
        AppiumConnect.initialize_appium(android_caps)
        expect(AppiumConnect.app_installed?).to eq(true)
        expect(AppiumConnect.app_state).to eq(:running_in_foreground)
        expect(AppiumConnect.orientation).to eq(:portrait)
        expect(AppiumConnect.window_size).to eq([1080, 2208])
        expect(AppiumConnect.keyboard_shown?).to eq(false)
        expect(AppiumConnect.current_context).to eq('NATIVE_APP')
        expect(AppiumConnect.available_contexts).to eq(['NATIVE_APP'])
        expect(AppiumConnect.is_webview?).to eq(false)
        expect(AppiumConnect.is_native_app?).to eq(true)
        rect = AppiumConnect.window_rect
        expect(rect.x).to eq(0)
        expect(rect.y).to eq(0)
        expect(rect.width).to eq(1080)
        expect(rect.height).to eq(2208)
      end

      it 'verifies Android app is terminated' do
        AppiumConnect.initialize_appium(android_caps)
        AppiumConnect.terminate_app
        expect(AppiumConnect.app_state).to eq(:not_running)
      end

      it 'verifies Android app can be removed and re-installed' do
        AppiumConnect.initialize_appium(android_caps)
        # verify app removal
        AppiumConnect.remove_app
        expect(AppiumConnect.app_installed?).to eq(false)
        expect(AppiumConnect.app_state).to eq(:not_installed)
        # verify app installation
        AppiumConnect.install_app(Environ.current.android_apk_path)
        expect(AppiumConnect.app_installed?).to eq(true)
        expect(AppiumConnect.app_state).to eq(:not_running)
      end

      it 'connects to Android Simulator with global driver scope' do
        options = {
          driver: :appium,
          device_type: :phone,
          global_driver: true,
          capabilities: {
            platformName: :android,
            'appium:platformVersion': '12.0',
            'appium:deviceName': 'Pixel_5_API_31',
            'appium:automationName': 'UiAutomator2',
            'appium:avd': 'Pixel_5_API_31',
            'appium:app': Environ.current.android_apk_path
          }
        }
        AppiumConnect.initialize_appium(options)
        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :android,
          os_version = '12.0',
          dev_name = 'Pixel_5_API_31'
        )
        expect($driver).to eq(Environ.appium_driver)
      end
    end
  end

  context 'Connect to locally hosted mobile device simulator using environment variables' do
    it 'connects to iOS iPhone Simulator using environment variables' do
      ENV['AUTOMATION_ENGINE'] = 'XCUITest'
      ENV['APP_PLATFORM_NAME'] = 'ios'
      ENV['APP_VERSION'] = '15.4'
      ENV['APP_DEVICE'] = 'iPhone 13 Pro Max'
      ENV['APP'] = Environ.current.ios_app_path
      AppiumConnect.initialize_appium
      verify_mobile_connect(
        dev_type = :phone,
        dev_os = :ios,
        os_version = '15.4',
        dev_name = 'iPhone 13 Pro Max'
      )
      expect($driver).to eq(nil)
    end

    it 'connects to Android Simulator using environment variables' do
      ENV['AUTOMATION_ENGINE'] = 'UiAutomator2'
      ENV['APP_PLATFORM_NAME'] = 'Android'
      ENV['APP_VERSION'] = '12.0'
      ENV['APP_DEVICE'] = 'Pixel_5_API_31'
      ENV['APP'] = Environ.current.android_apk_path
      AppiumConnect.initialize_appium
      verify_mobile_connect(
        dev_type = :phone,
        dev_os = :android,
        os_version = '12.0',
        dev_name = 'Pixel_5_API_31'
      )
      expect($driver).to eq(nil)
    end
  end

  def verify_mobile_connect(dev_type, dev_os, os_version, dev_name, driver_name = nil)
    # verify Environs are correctly set
    expect(Environ.driver).to eq(:appium)
    expect(Environ.platform).to eq(:mobile)
    expect(Environ.device).to eq(:simulator)
    expect(Environ.device_type).to eq(dev_type)
    expect(Environ.is_web?).to eq(false)
    expect(Environ.device_os).to eq(dev_os)
    expect(Environ.device_name).to eq(dev_name)
    expect(Environ.device_os_version).to eq(os_version)
    expect(Environ.appium_driver).not_to eq(nil)
    if dev_os == :ios
      expect(Environ.is_ios?).to eq(true)
    else
      expect(Environ.is_android?).to eq(true)
    end
    driver_name = "appium_#{Environ.device_os}_#{Environ.device_type}".downcase.to_sym if driver_name.nil?
    expect(Environ.driver_name).to eq(driver_name)
  end

  after(:each) do
    AppiumConnect.quit_driver
    Environ.driver = nil
    Environ.device_type = nil
    $driver = nil
  end

  after(:context) do
    $server.stop if Environ.driver == :appium && $server.running?
  end
end
