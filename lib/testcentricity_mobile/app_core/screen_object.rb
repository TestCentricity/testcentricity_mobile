require 'test/unit'

module TestCentricity
  class ScreenObject < BaseScreenSectionObject
    include Test::Unit::Assertions

    attr_reader :locator

    def initialize
      raise "Screen object #{self.class.name} does not have a screen_name trait defined" unless defined?(screen_name)
      @locator = screen_locator if defined?(screen_locator)
    end

    # Declare and instantiate a single generic UI Element for this screen object.
    #
    # @param element_name [Symbol] name of UI object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    #   The locator_strategy (a Symbol) specifies the selector strategy that Appium will use to find the UI element. Valid
    #   selectors are accessibility_id:, id:, name:, class:, xpath:, predicate: (iOS only), class_chain: (iOS only), and
    #   css: (WebViews in hybrid apps only).
    # * The locator_identifier (a String) is the value or attribute that uniquely and unambiguously identifies the UI element.
    #
    # @example
    #   element :video_player, { accessibility_id: 'YouTube Video Player' }
    #
    def self.element(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppUIElement, locator)
    end

    # Declare and instantiate a collection of generic UI Elements for this screen object.
    #
    # @param element_hash [Hash] names of UI objects (as a Symbol) and locator Hash
    # @example
    #   elements drop_down_field: { accessibility_id: 'drop_trigger' },
    #            settings_item: { accessibility_id: 'settings' },
    #            video_player: { accessibility_id: 'YouTube Video Player' }
    #
    def self.elements(element_hash)
      element_hash.each do |element_name, locator|
        element(element_name, locator)
      end
    end

    # Declare and instantiate a single button UI Element for this screen object.
    #
    # @param element_name [Symbol] name of button object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   button :video_play,  { accessibility_id: 'video icon play' }
    #
    def self.button(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppButton, locator)
    end

    # Declare and instantiate a collection of buttons for this screen object.
    #
    # @param element_hash [Hash] names of buttons (as symbol) and locator Hash
    # @example
    #   buttons video_back:    { accessibility_id: 'video icon backward' },
    #           video_play:    { accessibility_id: 'video icon play' },
    #           video_pause:   { accessibility_id: 'video icon stop' },
    #           video_forward: { accessibility_id: 'video icon forward' }
    #
    def self.buttons(element_hash)
      element_hash.each do |element_name, locator|
        button(element_name, locator)
      end
    end

    # Declare and instantiate a single textfield UI Element for this screen object.
    #
    # @param element_name [Symbol] name of textfield object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   textfield :payee_name_field, { xpath: '//android.widget.EditText[@content-desc="Full Name* input field"]' }
    #   textfield :payee_name_field, { xpath: '//XCUIElementTypeTextField[@name="Full Name* input field"]' }
    #
    def self.textfield(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppTextField, locator)
    end

    # Declare and instantiate a collection of textfields for this screen object.
    #
    # @param element_hash [Hash] names of textfields (as symbol) and locator Hash
    # @example
    #   textfields username_field: { accessibility_id: 'Username input field' },
    #              password_field: { accessibility_id: 'Password input field' }
    #
    def self.textfields(element_hash)
      element_hash.each do |element_name, locator|
        textfield(element_name, locator)
      end
    end

    # Declare and instantiate a single switch UI Element for this screen object.
    #
    # @param element_name [Symbol] name of switch object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   switch :debug_mode_switch, { accessibility_id: 'debug mode' }
    #
    def self.switch(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppSwitch, locator)
    end

    # Declare and instantiate a collection of switches for this screen object.
    #
    # @param element_hash [Hash] names of switches (as symbol) and locator Hash
    # @example
    #   switches debug_mode_switch: { accessibility_id: 'debug mode' },
    #            metrics_switch: { accessibility_id: 'metrics' }
    #
    def self.switches(element_hash)
      element_hash.each do |element_name, locator|
        switch(element_name, locator)
      end
    end

    # Declare and instantiate a single checkbox UI Element for this screen object.
    #
    # @param element_name [Symbol] name of checkbox object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   checkbox :bill_address_check, { xpath: '//XCUIElementTypeOther[contains(@name, "billing checkbox")]'}
    #
    def self.checkbox(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppCheckBox, locator)
    end

    # Declare and instantiate a collection of checkboxes for this screen object.
    #
    # @param element_hash [Hash] names of checkboxes (as symbol) and locator Hash
    # @example
    #   checkboxes bill_address_check: { xpath: '//XCUIElementTypeOther[contains(@name, "billing checkbox")]'},
    #              is_gift_check: { accessibility_id: 'is a gift' }
    #
    def self.checkboxes(element_hash)
      element_hash.each do |element_name, locator|
        checkbox(element_name, locator)
      end
    end

    # Declare and instantiate a single radio button UI Element for this screen object.
    #
    # @param element_name [Symbol] name of radio button object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   radio :unicode_radio, { xpath: '//XCUIElementTypeRadioButton[@label="Unicode"]'}
    #
    def self.radio(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppRadio, locator)
    end

    # Declare and instantiate a collection of radio buttons for this screen object.
    #
    # @param element_hash [Hash] names of radio buttons (as symbol) and locator Hash
    # @example
    #   radios unicode_radio: { xpath: '//XCUIElementTypeRadioButton[@label="Unicode"]'},
    #          ascii_radio:   { xpath: '//XCUIElementTypeRadioButton[@label="ASCII"] }
    #
    def self.radios(element_hash)
      element_hash.each do |element_name, locator|
        radio(element_name, locator)
      end
    end

    # Declare and instantiate a single label UI Element for this screen object.
    #
    # @param element_name [Symbol] name of label object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   label :header_label, { accessibility_id: 'container header' }
    #
    def self.label(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppLabel, locator)
    end

    # Declare and instantiate a collection of labels for this screen object.
    #
    # @param element_hash [Hash] names of labels (as symbol) and locator Hash
    # @example
    #   labels total_qty_value:   { accessibility_id: 'total number' },
    #          total_price_value: { accessibility_id: 'total price' }
    #
    def self.labels(element_hash)
      element_hash.each do |element_name, locator|
        label(element_name, locator)
      end
    end

    # Declare and instantiate a single list UI Element for this screen object.
    #
    # @param element_name [Symbol] name of list object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   list :carousel_list, { accessibility_id: 'Carousel' }
    #
    def self.list(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppList, locator)
    end

    # Declare and instantiate a collection of lists for this screen object.
    #
    # @param element_hash [Hash] names of lists (as symbol) and locator Hash
    # @example
    #   lists product_grid: { xpath: '//android.widget.ScrollView/android.view.ViewGroup' },
    #         cart_list: { xpath: '//android.widget.ScrollView[@content-desc="cart screen"]' }
    #
    def self.lists(element_hash)
      element_hash.each do |element_name, locator|
        list(element_name, locator)
      end
    end

    # Declare and instantiate a single image UI Element for this screen object.
    #
    # @param element_name [Symbol] name of image object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   image :product_image, { xpath: '//XCUIElementTypeImage' }
    #
    def self.image(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppImage, locator)
    end

    # Declare and instantiate a collection of images for this screen object.
    #
    # @param element_hash [Hash] names of images (as symbol) and locator Hash
    # @example
    #   images empty_cart_image: { accessibility_id: 'empty_cart' },
    #          logo_image: { accessibility_id: 'WebdriverIO logo' }
    #
    def self.images(element_hash)
      element_hash.each do |element_name, locator|
        image(element_name, locator)
      end
    end

    # Declare and instantiate a single alert UI Element for this screen object.
    #
    # @param element_name [Symbol] name of alert object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   alert :generic_alert_modal, { id: 'android:id/parentPanel' }
    #   alert :generic_alert_modal, { class: 'XCUIElementTypeAlert' }
    #
    def self.alert(element_name, locator)
      define_screen_element(element_name, TestCentricity::AppElements::AppAlert, locator)
    end

    # Declare and instantiate a collection of alerts for this screen object.
    #
    # @param element_hash [Hash] names of alerts (as symbol) and locator Hash
    # @example
    #   alerts grant_modal: { id: 'com.android.permissioncontroller:id/grant_dialog' },
    #          alert_modal: { id: 'android:id/parentPanel' }
    #
    def self.alerts(element_hash)
      element_hash.each do |element_name, locator|
        alert(element_name, locator)
      end
    end

    # Instantiate a single ScreenSection object within this ScreenObject.
    #
    # @param section_name [Symbol] name of ScreenSection object (as a symbol)
    # @param class_name [Class] Class name of ScreenSection object
    # @example
    #   section :nav_menu, NavMenu
    #
    def self.section(section_name, obj, locator = 0)
      define_screen_element(section_name, obj, locator)
    end

    # Declare and instantiate a collection of ScreenSection objects for this screen object.
    #
    # @param element_hash [Hash] names of ScreenSections (as symbol) and class name
    # @example
    #   sections nav_bar:  NavBar,
    #            nav_menu: NavMenu
    #
    def self.sections(section_hash)
      section_hash.each do |section_name, class_name|
        section(section_name, class_name)
      end
    end

    # Does Screen object exists?
    #
    # @return [Boolean]
    # @example
    #   home_screen.exists?
    #
    def exists?
      @locator.is_a?(Array) ? tries ||= 2 : tries ||= 1
      if @locator.is_a?(Array)
        loc = @locator[tries - 1]
        find_element(loc.keys[0], loc.values[0])
      else
        find_element(@locator.keys[0], @locator.values[0])
      end
      true
    rescue
      retry if (tries -= 1) > 0
      false
    end

    # Wait until the Screen object exists, or until the specified wait time has expired. If the wait time is nil, then
    # the wait time will be Environ.default_max_wait_time.
    #
    # @param seconds [Integer or Float] wait time in seconds
    # @example
    #   cart_screen.wait_until_exists(15)
    #
    def wait_until_exists(seconds = nil, post_exception = true)
      timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
      wait = Selenium::WebDriver::Wait.new(timeout: timeout)
      wait.until { exists? }
    rescue
      if post_exception
        raise "Screen object #{self.class.name} not found after #{timeout} seconds" unless exists?
      else
        exists?
      end
    end

    # Wait until the Screen object is gone, or until the specified wait time has expired. If the wait time is nil, then
    # the wait time will be Environ.default_max_wait_time.
    #
    # @param seconds [Integer or Float] wait time in seconds
    # @example
    #   login_screen.wait_until_gone(15)
    #
    def wait_until_gone(seconds = nil, post_exception = true)
      timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
      wait = Selenium::WebDriver::Wait.new(timeout: timeout)
      wait.until { !exists? }
    rescue
      if post_exception
        raise "Screen object #{self.class.name} remained visible after #{timeout} seconds" if exists?
      else
        exists?
      end
    end

    def navigate_to; end

    def verify_screen_ui; end

    # Verifies that the target screen is displayed, and sets ScreenManager.current_screen to reference the target screen
    # instance.
    #
    def verify_screen_exists
      wait = Selenium::WebDriver::Wait.new(timeout: Environ.default_max_wait_time)
      wait.until { exists? }
      ScreenManager.current_screen = self
    rescue
      raise "Could not find screen_locator for screen object '#{self.class.name}' (#{@locator}) after #{Environ.default_max_wait_time} seconds"
    end

    # Load the screen using its defined deep_link trait. When testing on physical iOS devices running iOS/iPadOS versions
    # earlier than version 16.4, deep links can only be opened by sending the deeplink URL to the mobile Safari web browser,
    # and then accepting the confirmation modal that pops up. This method handles invoking deeplinks on Android and iOS/iPadOS
    # simulators and physical devices.
    #
    # This method verifies that the target screen is loaded and displayed, and sets ScreenManager.current_screen to reference
    # the target screen instance.
    #
    # @example
    #   cart_screen.load_screen
    #
    def load_screen
      # return if target screen is already loaded
      if exists?
        ScreenManager.current_screen = self
        return
      end

      url = if deep_link.include?("://")
              deep_link
            elsif !Environ.current.deep_link_prefix.blank?
              "#{Environ.current.deep_link_prefix}://#{deep_link}"
            end

      if Environ.is_android?
        Environ.appium_driver.execute_script('mobile:deepLink', { url: url, package: Environ.current.android_app_id })
      elsif Environ.is_ios?
        if Environ.is_device? && Environ.device_os_version.to_f < 16.4
          # launch Safari browser on iOS real device if iOS version is below 16.4
          Environ.appium_driver.execute_script('mobile: launchApp', { bundleId: 'com.apple.mobilesafari' })
          unless Environ.appium_driver.is_keyboard_shown
            begin
              # attempt to find and click URL button on iOS 15 Safari browser
              find_element(:accessibility_id, 'TabBarItemTitle').click
            rescue
              # fall back to URL button on iOS 14 Safari browser
              find_element(:xpath, '//XCUIElementTypeButton[@name="URL"]').click
            end
          end
          # enter deep-link URL
          wait_for_object(:xpath, '//XCUIElementTypeTextField[@name="URL"]', 5).send_keys("#{url}\uE007")
          # wait for and accept the popup modal
          wait_for_object(:xpath, '//XCUIElementTypeButton[@name="Open"]', 10).click
        else
          # iOS version is >= 16.4 so directly load screen via deepLink
          Environ.appium_driver.get(url)
        end
      else
        raise "#{Environ.device_os} is not supported"
      end
      verify_screen_exists
    end

    private

    def self.define_screen_element(element_name, obj, locator)
      define_method(element_name) do
        ivar_name = "@#{element_name}"
        ivar = instance_variable_get(ivar_name)
        return ivar if ivar
        instance_variable_set(ivar_name, obj.new(element_name, self, locator, :screen))
      end
    end

    def wait_for_object(find_method, locator, seconds)
      wait = Selenium::WebDriver::Wait.new(timeout: seconds)
      obj = nil
      wait.until do
        obj = find_element(find_method, locator)
        obj.displayed?
      end
      obj
    end
  end
end
