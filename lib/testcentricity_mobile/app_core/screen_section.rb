require 'test/unit'

module TestCentricity
  class ScreenSection < BaseScreenSectionObject
    include Test::Unit::Assertions

    attr_reader   :context, :name
    attr_accessor :locator
    attr_accessor :parent
    attr_accessor :parent_list
    attr_accessor :list_index

    def initialize(name, parent, locator, context)
      @name        = name
      @parent      = parent
      @locator     = locator
      @context     = context
      @parent_list = nil
      @list_index  = nil
    end

    def get_locator
      my_locator = if @locator.zero? && defined?(section_locator)
                     section_locator
                   else
                     @locator
                   end
      locators = []
      if @context == :section && !@parent.nil?
        locators = @parent.get_locator
      end

      if @parent_list.nil?
        locators.push(my_locator)
      else
        locators.push(@parent_list.get_locator)
        if @list_index.nil?
          locators.push(my_locator)
        else
          item_objects = @parent_list.item_refs
          if item_objects.nil?
            list_key = my_locator.keys[0]
            list_value = "#{my_locator.values[0]}[#{@list_index}]"
          else
            list_key = :object
            list_value = item_objects[@list_index - 1]
          end
          locators.push( { list_key => list_value } )
        end
      end
      locators
    end

    def set_list_index(list, index = 1)
      @parent_list = list unless list.nil?
      @list_index  = index
    end

    def get_item_count
      raise 'No parent list defined' if @parent_list.nil?
      @parent_list.get_item_count
    end

    def get_list_items
      items = []
      (1..get_item_count).each do |item|
        set_list_index(nil, item)
        begin
          items.push(get_value)
        rescue
          scroll_into_view(@parent_list.scroll_mode)
          items.push(get_value)
        end
      end
      items
    end

    def get_object_type
      :section
    end

    def get_name
      @name
    end

    def set_parent(parent)
      @parent = parent
    end

    # Declare and instantiate a single generic UI Element for this screen section object.
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
      define_section_element(element_name, TestCentricity::AppElements::AppUIElement, locator)
    end

    # Declare and instantiate a collection of generic UI Elements for this screen section object.
    #
    # @param element_hash [Hash] names of UI objects (as a Symbol) and locator Hash
    # @example
    #   elements drop_down_field: { accessibility_id: 'drop_trigger' },
    #            settings_item: { accessibility_id: 'settings' },
    #            log_out_item:  { accessibility_id: 'logout' }
    #
    def self.elements(element_hash)
      element_hash.each_pair { |element_name, locator| element(element_name, locator) }
    end

    # Declare and instantiate a single button UI Element for this screen section object.
    #
    # @param element_name [Symbol] name of button object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   button :video_play,  { accessibility_id: 'video icon play' }
    #
    def self.button(element_name, locator)
      define_section_element(element_name, TestCentricity::AppElements::AppButton, locator)
    end

    # Declare and instantiate a collection of buttons for this screen section object.
    #
    # @param element_hash [Hash] names of buttons (as symbol) and locator Hash
    # @example
    #   buttons video_back:    { accessibility_id: 'video icon backward' },
    #           video_play:    { accessibility_id: 'video icon play' },
    #           video_pause:   { accessibility_id: 'video icon stop' },
    #           video_forward: { accessibility_id: 'video icon forward' }
    #
    def self.buttons(element_hash)
      element_hash.each_pair { |element_name, locator| button(element_name, locator) }
    end

    # Declare and instantiate a single textfield UI Element for this screen section object.
    #
    # @param element_name [Symbol] name of textfield object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   textfield :payee_name_field, { xpath: '//android.widget.EditText[@content-desc="Full Name* input field"]' }
    #   textfield :payee_name_field, { xpath: '//XCUIElementTypeTextField[@name="Full Name* input field"]' }
    #
    def self.textfield(element_name, locator)
      define_section_element(element_name, TestCentricity::AppElements::AppTextField, locator)
    end

    # Declare and instantiate a collection of textfields for this screen section object.
    #
    # @param element_hash [Hash] names of textfields (as symbol) and locator Hash
    # @example
    #   textfields username_field: { accessibility_id: 'Username input field' },
    #              password_field: { accessibility_id: 'Password input field' }
    #
    def self.textfields(element_hash)
      element_hash.each_pair { |element_name, locator| textfield(element_name, locator) }
    end

    # Declare and instantiate a single switch UI Element for this screen section object.
    #
    # @param element_name [Symbol] name of switch object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   switch :debug_mode_switch, { accessibility_id: 'debug mode' }
    #
    def self.switch(element_name, locator)
      define_section_element(element_name, TestCentricity::AppElements::AppSwitch, locator)
    end

    # Declare and instantiate a collection of switches for this screen section object.
    #
    # @param element_hash [Hash] names of switches (as symbol) and locator Hash
    # @example
    #   switches debug_mode_switch: { accessibility_id: 'debug mode' },
    #            metrics_switch: { accessibility_id: 'metrics' }
    #
    def self.switches(element_hash)
      element_hash.each_pair { |element_name, locator| switch(element_name, locator) }
    end

    # Declare and instantiate a single checkbox UI Element for this screen section object.
    #
    # @param element_name [Symbol] name of checkbox object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   checkbox :bill_address_check, { xpath: '//XCUIElementTypeOther[contains(@name, "billing checkbox")]'}
    #
    def self.checkbox(element_name, locator)
      define_section_element(element_name, TestCentricity::AppElements::AppCheckBox, locator)
    end

    # Declare and instantiate a collection of checkboxes for this screen section object.
    #
    # @param element_hash [Hash] names of checkboxes (as symbol) and locator Hash
    # @example
    #   checkboxes bill_address_check: { xpath: '//XCUIElementTypeOther[contains(@name, "billing checkbox")]'},
    #              is_gift_check: { accessibility_id: 'is a gift' }
    #
    def self.checkboxes(element_hash)
      element_hash.each_pair { |element_name, locator| checkbox(element_name, locator) }
    end

    # Declare and instantiate a single radio button UI Element for this screen section object.
    #
    # @param element_name [Symbol] name of radio button object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   radio :unicode_radio, { xpath: '//XCUIElementTypeRadioButton[@label="Unicode"]'}
    #
    def self.radio(element_name, locator)
      define_section_element(element_name, TestCentricity::AppElements::AppRadio, locator)
    end

    # Declare and instantiate a collection of radio buttons for this screen section object.
    #
    # @param element_hash [Hash] names of radio buttons (as symbol) and locator Hash
    # @example
    #   radios unicode_radio: { xpath: '//XCUIElementTypeRadioButton[@label="Unicode"]'},
    #          ascii_radio:   { xpath: '//XCUIElementTypeRadioButton[@label="ASCII"] }
    #
    def self.radios(element_hash)
      element_hash.each_pair { |element_name, locator| radio(element_name, locator) }
    end

    # Declare and instantiate a single label UI Element for this screen section object.
    #
    # @param element_name [Symbol] name of label object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   label :header_label, { accessibility_id: 'container header' }
    #
    def self.label(element_name, locator)
      define_section_element(element_name, TestCentricity::AppElements::AppLabel, locator)
    end

    # Declare and instantiate a collection of labels for this screen section object.
    #
    # @param element_hash [Hash] names of labels (as symbol) and locator Hash
    # @example
    #   labels total_qty_value:   { accessibility_id: 'total number' },
    #          total_price_value: { accessibility_id: 'total price' }
    #
    def self.labels(element_hash)
      element_hash.each_pair { |element_name, locator| label(element_name, locator) }
    end

    # Declare and instantiate a single list UI Element for this screen section object.
    #
    # @param element_name [Symbol] name of list object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   list :carousel_list, { accessibility_id: 'Carousel' }
    #
    def self.list(element_name, locator)
      define_section_element(element_name, TestCentricity::AppElements::AppList, locator)
    end

    # Declare and instantiate a collection of lists for this screen section object.
    #
    # @param element_hash [Hash] names of lists (as symbol) and locator Hash
    # @example
    #   lists product_grid: { xpath: '//android.widget.ScrollView/android.view.ViewGroup' },
    #         cart_list: { xpath: '//android.widget.ScrollView[@content-desc="cart screen"]' }
    #
    def self.lists(element_hash)
      element_hash.each_pair { |element_name, locator| list(element_name, locator) }
    end

    # Declare and instantiate a single image UI Element for this screen section object.
    #
    # @param element_name [Symbol] name of image object (as a symbol)
    # @param locator [Hash] { locator_strategy: locator_identifier }
    # @example
    #   image :product_image, { xpath: '//XCUIElementTypeImage' }
    #
    def self.image(element_name, locator)
      define_section_element(element_name, TestCentricity::AppElements::AppImage, locator)
    end

    # Declare and instantiate a collection of images for this screen section object.
    #
    # @param element_hash [Hash] names of images (as symbol) and locator Hash
    # @example
    #   images empty_cart_image: { accessibility_id: 'empty_cart' },
    #          logo_image: { accessibility_id: 'WebdriverIO logo' }
    #
    def self.images(element_hash)
      element_hash.each_pair { |element_name, locator| image(element_name, locator) }
    end

    # Instantiate a single ScreenSection object within this ScreenSection object.
    #
    # @param section_name [Symbol] name of ScreenSection object (as a symbol)
    # @param class_name [Class] Class name of ScreenSection object
    # @example
    #   section :nav_menu, NavMenu
    #
    def self.section(section_name, obj, locator = 0)
      define_section_element(section_name, obj, locator)
    end

    # Declare and instantiate a collection of ScreenSection objects for this ScreenSection object.
    #
    # @param element_hash [Hash] names of ScreenSections (as symbol) and class name
    # @example
    #   sections product_grid_item: ProductGridItem,
    #            sort_by_menu:      SortByMenu
    #
    def self.sections(section_hash)
      section_hash.each_pair { |section_name, class_name| section(section_name, class_name) }
    end

    # Click on a screen Section object
    #
    # @example
    #   bar_chart_section.click
    #
    def click
      section = find_section
      section_not_found_exception(section)
      section.click
    end

    # Tap on a screen Section object
    #
    # @example
    #   bar_chart_section.tap
    #
    def tap
      section = find_section
      section_not_found_exception(section)
      driver.action
            .click_and_hold(section)
            .release
            .perform
    end

    # Double-tap on a screen Section object
    #
    # @example
    #   bar_chart_section.double_tap
    #
    def double_tap
      section = find_section
      section_not_found_exception(section)
      driver.action
            .click_and_hold(section)
            .release
            .pause(duration: 0.2)
            .click_and_hold(section)
            .release
            .perform
    end

    # Long press on a screen Section object
    #
    # @param duration [Float] duration of long press in seconds
    # @example
    #   header_image.long_press(1.5)
    #
    def long_press(duration = 1)
      section = find_section
      section_not_found_exception(section)
      driver.action
            .click_and_hold(section)
            .pause(duration: duration)
            .release
            .perform
    end

    # Scroll the screen Section object until it is visible. If scroll_mode is not specified, then vertical scrolling will
    # be used.
    #
    # @param scroll_mode [Symbol] :vertical (default) or :horizontal
    # @example
    #   carousel_item.scroll_into_view(scroll_mode = :horizontal)
    #
    def scroll_into_view(scroll_mode = :vertical)
      return if visible?
      obj = element
      object_not_found_exception(obj)
      driver.action.move_to(obj).perform
      case scroll_mode
      when :vertical
        start_direction = :down
        end_direction = :up
      when :horizontal
        start_direction = :right
        end_direction = :left
      else
        raise "#{scroll_mode} is not a valid selector"
      end
      try_count = 8
      direction = start_direction
      while hidden?
        swipe_gesture(direction, distance = 0.2)
        try_count -= 1
        if try_count.zero?
          if direction == end_direction
            break
          else
            direction = end_direction
            try_count = 8
          end
        end
      end
    end

    # Does screen Section object exists?
    #
    # @return [Boolean]
    # @example
    #   navigation_toolbar.exists?
    #
    def exists?
      section = find_section
      section != nil
    end

    # Is screen Section object enabled?
    #
    # @return [Boolean]
    # @example
    #   bar_chart_section.enabled?
    #
    def enabled?
      section = find_section
      section_not_found_exception(section)
      section.enabled?
    end

    # Is screen Section object disabled (not enabled)?
    #
    # @return [Boolean]
    # @example
    #   bar_chart_section.disabled?
    #
    def disabled?
      !enabled?
    end

    # Is screen Section object visible?
    #
    # @return [Boolean]
    # @example
    #   navigation_toolbar.visible?
    #
    def visible?
      section = find_section
      return false if section.nil?

      section.displayed?
    end

    # Is screen Section object hidden (not visible)?
    #
    # @return [Boolean]
    # @example
    #   navigation_toolbar.hidden?
    #
    def hidden?
      !visible?
    end

    # Wait until the screen Section object exists, or until the specified wait time has expired. If the wait time is nil,
    # then the wait time will be Environ.default_max_wait_time.
    #
    # @param seconds [Integer or Float] wait time in seconds
    # @example
    #   navigation_toolbar.wait_until_exists(1.5)
    #
    def wait_until_exists(seconds = nil, post_exception = true)
      timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
      wait = Selenium::WebDriver::Wait.new(timeout: timeout)
      wait.until { exists? }
    rescue
      if post_exception
        raise "Could not find Section object '#{get_name}' (#{get_locator}) after #{timeout} seconds" unless exists?
      else
        exists?
      end
    end

    # Wait until the screen Section object no longer exists, or until the specified wait time has expired. If the wait
    # time is nil, then the wait time will be Environ.default_max_wait_time.
    #
    # @param seconds [Integer or Float] wait time in seconds
    # @example
    #   navigation_toolbar.wait_until_gone(5)
    #
    def wait_until_gone(seconds = nil, post_exception = true)
      timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
      wait = Selenium::WebDriver::Wait.new(timeout: timeout)
      wait.until { !exists? }
    rescue
      if post_exception
        raise "Section object '#{get_name}' (#{get_locator}) remained visible after #{timeout} seconds" if exists?
      else
        exists?
      end
    end

    # Wait until the screen Section object is visible, or until the specified wait time has expired. If the wait time is nil,
    # then the wait time will be Environ.default_max_wait_time.
    #
    # @param seconds [Integer or Float] wait time in seconds
    # @example
    #   navigation_toolbar.wait_until_visible(1.5)
    #
    def wait_until_visible(seconds = nil, post_exception = true)
      timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
      wait = Selenium::WebDriver::Wait.new(timeout: timeout)
      wait.until { visible? }
    rescue
      if post_exception
        raise "Could not find Section object '#{get_name}' (#{get_locator}) after #{timeout} seconds" unless visible?
      else
        visible?
      end
    end

    # Wait until the screen Section object is hidden, or until the specified wait time has expired. If the wait time is nil,
    # then the wait time will be Environ.default_max_wait_time.
    #
    # @param seconds [Integer or Float] wait time in seconds
    # @example
    #   navigation_toolbar.wait_until_hidden(2)
    #
    def wait_until_hidden(seconds = nil, post_exception = true)
      timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
      wait = Selenium::WebDriver::Wait.new(timeout: timeout)
      wait.until { hidden? }
    rescue
      if post_exception
        raise "Section object '#{get_name}' (#{get_locator}) remained visible after #{timeout} seconds" if visible?
      else
        visible?
      end
    end

    # Return width of screen Section object.
    #
    # @return [Integer]
    # @example
    #   button_width = my_button.width
    #
    def width
      section = find_section
      section_not_found_exception(section)
      section.size.width
    end

    # Return height of screen Section object.
    #
    # @return [Integer]
    # @example
    #   button_height = my_button.height
    #
    def height
      section = find_section
      section_not_found_exception(section)
      section.size.height
    end

    # Return x coordinate of screen Section object's location.
    #
    # @return [Integer]
    # @example
    #   button_x = my_button.x_loc
    #
    def x_loc
      section = find_section
      section_not_found_exception(section)
      section.location.x
    end

    # Return y coordinate of screen Section object's location.
    #
    # @return [Integer]
    # @example
    #   button_x = my_button.x_loc
    #
    def y_loc
      section = find_section
      section_not_found_exception(section)
      section.location.y
    end

    private

    def find_section
      obj = nil
      locators = get_locator
      locators.each do |loc|
        if obj.nil?
          obj = find_element(loc.keys[0], loc.values[0])
        else
          obj = obj.find_element(loc.keys[0], loc.values[0])
        end
        puts "Found section object #{loc}" if ENV['DEBUG']
      end
      obj
    rescue
      nil
    end

    def section_not_found_exception(obj)
      raise ObjectNotFoundError.new("Section object '#{get_name}' (#{get_locator}) not found") unless obj
    end

    def self.define_section_element(element_name, obj, locator)
      define_method(element_name) do
        ivar_name = "@#{element_name}"
        ivar = instance_variable_get(ivar_name)
        return ivar if ivar
        instance_variable_set(ivar_name, obj.new(element_name, self, locator, :section))
      end
    end
  end
end
