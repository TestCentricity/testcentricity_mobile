require 'test/unit'

module TestCentricity
  module AppElements
    class AppUIElement
      include Test::Unit::Assertions

      attr_reader :parent, :locator, :context, :type, :name
      attr_accessor :mru_object, :mru_locator, :mru_parent, :mru_app_session

      def initialize(name, parent, locator, context)
        @name = name
        @parent = parent
        @locator = locator
        @context = context
        @type = nil
        reset_mru_cache
      end

      def reset_mru_cache
        @mru_object = nil
        @mru_locator = nil
        @mru_parent = nil
        @mru_app_session = nil
      end

      def get_object_type
        @type
      end

      def get_locator
        @locator
      end

      def get_name
        @name
      end

      def set(value)
        obj = element
        object_not_found_exception(obj)
        if value.is_a?(Array)
          obj.send_keys(value[0])
          if value[1].is_a?(Integer)
            press_keycode(value[1])
          else
            obj.send_keys(value[1])
          end
        elsif value.is_a?(String)
          obj.send_keys(value)
        end
      end

      # Send keystrokes to this UI element.
      #
      # @param value [String] keys
      # @example
      #   color_picker_wheel.send_keys('Lime green')
      #
      def send_keys(value)
        obj = element
        object_not_found_exception(obj)
        obj.send_keys(value)
      end

      def clear
        obj = element
        object_not_found_exception(obj)
        obj.clear
      end

      def get_value
        obj = element
        object_not_found_exception(obj)
        if AppiumConnect.is_webview?
          case obj.tag_name.downcase
          when 'input', 'select', 'textarea'
            obj.value
          else
            obj.text
          end
        else
          obj.text
        end
      end

      alias value get_value

      def get_caption
        obj = element
        object_not_found_exception(obj)
        if AppiumConnect.is_webview?
          case obj.tag_name.downcase
          when 'input', 'select', 'textarea'
            obj.value
          else
            obj.text
          end
        elsif Environ.is_ios?
          caption = case obj.tag_name
                    when 'XCUIElementTypeNavigationBar'
                      obj.attribute(:name)
                    else
                      obj.attribute(:label)
                    end
          caption = '' if caption.nil?
        else
          caption = obj.text
          if caption.blank?
            case obj.attribute(:class)
            when 'android.view.ViewGroup'
              caption_obj = obj.find_element(:xpath, '//android.widget.TextView')
              caption = caption_obj.text
            when 'android.widget.Button'
              caption_obj = obj.find_element(:xpath, '//android.widget.TextView')
              caption = caption_obj.text
              if caption.blank?
                caption_obj = obj.find_element(:xpath, '//android.widget.ViewGroup/android.widget.TextView')
                caption = caption_obj.text
              end
            end
          end
        end
        caption
      end

      alias caption get_caption

      # Does UI object exists?
      #
      # @return [Boolean]
      # @example
      #   empty_cart_image.exists?
      #
      def exists?
        obj = element
        !obj.nil?
      end

      # Is UI object visible?
      #
      # @return [Boolean]
      # @example
      #   remember_me_checkbox.visible?
      #
      def visible?
        obj = element
        return false if obj.nil?
        begin
          obj.displayed?
        rescue
          reset_mru_cache
          obj = element
          return false if obj.nil?
          obj.displayed?
        end
      end

      # Is UI object hidden (not visible)?
      #
      # @return [Boolean]
      # @example
      #   remember_me_checkbox.hidden?
      #
      def hidden?
        !visible?
      end

      # Is UI object enabled?
      #
      # @return [Boolean]
      # @example
      #   login_button.enabled?
      #
      def enabled?
        obj = element
        object_not_found_exception(obj)
        obj.enabled?
      end

      # Is UI object disabled (not enabled)?
      #
      # @return [Boolean]
      # @example
      #   refresh_button.disabled?
      #
      def disabled?
        !enabled?
      end

      def selected?
        obj = element
        object_not_found_exception(obj)
        obj.selected?
      end

      def get_attribute(attrib)
        obj = element
        object_not_found_exception(obj)
        obj.attribute(attrib)
      end

      # Wait until the object exists, or until the specified wait time has expired. If the wait time is nil, then the wait
      # time will be Environ.default_max_wait_time.
      #
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   run_button.wait_until_exists(0.5)
      #
      def wait_until_exists(seconds = nil, post_exception = true)
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until do
          reset_mru_cache
          exists?
        end
      rescue
        if post_exception
          raise "Could not find UI #{object_ref_message} after #{timeout} seconds" unless exists?
        else
          exists?
        end
      end

      # Wait until the object no longer exists, or until the specified wait time has expired. If the wait time is nil, then
      # the wait time will be Environ.default_max_wait_time.
      #
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   logout_button.wait_until_gone(5)
      #
      def wait_until_gone(seconds = nil, post_exception = true)
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until do
          reset_mru_cache
          !exists?
        end
      rescue
        if post_exception
          raise "UI #{object_ref_message} remained visible after #{timeout} seconds" if exists?
        else
          exists?
        end
      end

      # Wait until the object is visible, or until the specified wait time has expired. If the wait time is nil, then the
      # wait time will be Environ.default_max_wait_time.
      #
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   run_button.wait_until_visible(0.5)
      #
      def wait_until_visible(seconds = nil, post_exception = true)
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until do
          reset_mru_cache
          visible?
        end
      rescue
        if post_exception
          raise "Could not find UI #{object_ref_message} after #{timeout} seconds" unless visible?
        else
          visible?
        end
      end

      # Wait until the object is hidden, or until the specified wait time has expired. If the wait time is nil, then the
      # wait time will be Environ.default_max_wait_time.
      #
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   run_button.wait_until_hidden(10)
      #
      def wait_until_hidden(seconds = nil, post_exception = true)
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until do
          reset_mru_cache
          hidden?
        end
      rescue
        if post_exception
          raise "UI #{object_ref_message} remained visible after #{timeout} seconds" if visible?
        else
          hidden?
        end
      end

      # Wait until the object is enabled, or until the specified wait time has expired. If the wait time is nil, then the
      # wait time will be Environ.default_max_wait_time.
      #
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   run_button.wait_until_enabled(10)
      #
      def wait_until_enabled(seconds = nil, post_exception = true)
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until do
          reset_mru_cache
          enabled?
        end
      rescue
        if post_exception
          raise "UI #{object_ref_message} remained disabled after #{timeout} seconds" unless enabled?
        else
          enabled?
        end
      end

      # Wait until the object's value equals the specified value, or until the specified wait time has expired. If the wait
      # time is nil, then the wait time will be Environ.default_max_wait_time.
      #
      # @param value [String or Hash] value expected or comparison hash
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   card_authorized_label.wait_until_value_is('Card authorized', 5)
      #     or
      #   total_weight_field.wait_until_value_is({ :greater_than => '250' }, 5)
      #
      def wait_until_value_is(value, seconds = nil, post_exception = true)
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until do
          reset_mru_cache
          compare(value, get_value)
        end
      rescue
        if post_exception
          raise "Value of UI #{object_ref_message} failed to equal '#{value}' after #{timeout} seconds" unless get_value == value
        else
          get_value == value
        end
      end

      # Wait until the object's value changes to a different value, or until the specified wait time has expired. If the
      # wait time is nil, then the wait time will be Environ.default_max_wait_time.
      #
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   basket_grand_total_label.wait_until_value_changes(5)
      #
      def wait_until_value_changes(seconds = nil, post_exception = true)
        value = get_value
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until do
          reset_mru_cache
          get_value != value
        end
      rescue
        if post_exception
          raise "Value of UI #{object_ref_message} failed to change from '#{value}' after #{timeout} seconds" if get_value == value
        else
          get_value == value
        end
      end

      # Return width of object.
      #
      # @return [Integer]
      # @example
      #   button_width = my_button.width
      #
      def width
        obj = element
        object_not_found_exception(obj)
        obj.size.width
      end

      # Return height of object.
      #
      # @return [Integer]
      # @example
      #   button_height = my_button.height
      #
      def height
        obj = element
        object_not_found_exception(obj)
        obj.size.height
      end

      # Return x coordinate of object's location.
      #
      # @return [Integer]
      # @example
      #   button_x = my_button.x_loc
      #
      def x_loc
        obj = element
        object_not_found_exception(obj)
        obj.location.x
      end

      # Return y coordinate of object's location.
      #
      # @return [Integer]
      # @example
      #   button_y = my_button.y_loc
      #
      def y_loc
        obj = element
        object_not_found_exception(obj)
        obj.location.y
      end

      # Return the number of occurrences of an object with an ambiguous locator that evaluates to multiple UI elements.
      #
      # @return [Integer]
      # @example
      #   num_items = store_item.count
      #
      def count
        objs = find_elements(@locator.keys[0], @locator.values[0])
        objs.count
      end

      # Click on a UI element
      #
      # @example
      #   login_button.click
      #
      def click
        obj = element
        object_not_found_exception(obj)
        obj.click
      end

      # Tap on a UI element
      #
      # @example
      #   bar_chart_close.tap
      #
      def tap
        obj = element
        object_not_found_exception(obj)
        driver.action
              .click_and_hold(obj)
              .release
              .perform
      end

      # Double-tap on a UI element
      #
      # @example
      #   refresh_chart_button.double_tap
      #
      def double_tap
        obj = element
        object_not_found_exception(obj)
        driver.action
              .click_and_hold(obj)
              .release
              .pause(duration: 0.2)
              .click_and_hold(obj)
              .release
              .perform
      end

      # Long press on a UI element
      #
      # @param duration [Float] duration of long press in seconds
      # @example
      #   header_image.long_press(1.5)
      #
      def long_press(duration = 1)
        obj = element
        object_not_found_exception(obj)
        if Environ.is_ios?
          begin
            Environ.appium_driver.execute_script('mobile: touchAndHold', { elementId: obj.id, duration: duration })
          rescue => err
            puts "Retrying longpress due to error: #{err}"
          else
            return
          end
        end
        driver.action
              .click_and_hold(obj)
              .pause(duration: duration)
              .release
              .perform
      end

      # Drag the UI object by the specified offset. If the optional duration parameter is not specified, the duration
      # defaults to 0.3 seconds (300 milliseconds).
      #
      # @param right_offset [Integer] x coordinate offset
      # @param down_offset [Integer] y coordinate offset
      # @param duration [Float] OPTIONAL duration of drag in seconds
      # @example
      #   puzzle_21_piece.drag_by(-100, -300)
      #
      def drag_by(right_offset, down_offset, duration = 0.3)
        obj = element
        object_not_found_exception(obj)
        driver.action
              .click_and_hold(obj)
              .move_by(right_offset, down_offset, duration: duration)
              .release
              .perform
      end

      # Drag the UI object to the specified target object. If the optional duration parameter is not specified, the
      # duration defaults to 0.3 seconds (300 milliseconds).
      #
      # @param target [String] target object to drag to
      # @param duration [Float] OPTIONAL duration of drag in seconds
      # @example
      #   puzzle_21_piece.drag_and_drop(puzzle_21_slot)
      #
      def drag_and_drop(target, duration = 0.3)
        drag = element
        object_not_found_exception(drag)
        drop = target.element
        drag_x = drag.location.x
        drag_y = drag.location.y
        drop_x = drop.location.x
        drop_y = drop.location.y
        driver.action
              .click_and_hold(drag)
              .move_by(drop_x - drag_x, drop_y - drag_y, duration: duration)
              .release
              .perform
      end

      # Scroll the UI object until it is visible. If scroll_mode is not specified, then vertical scrolling will be used.
      #
      # @param scroll_mode [Symbol] :vertical (default) or :horizontal
      # @example
      #   place_order_button.scroll_into_view(scroll_mode = :horizontal)
      #
      def scroll_into_view(scroll_mode = :vertical)
        return if visible?
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
          ScreenManager.current_screen.swipe_gesture(direction, distance = 0.1)
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

      # Perform a swipe gesture on the UI object in the specified direction. The swipe start point is the center of the
      # UI object, and the swipe end point is the distance specified.
      #
      # A distance of 1 specifies a swipe gesture with a distance that is the full screen height (vertical swipe), or full
      # screen width (horizontal swipe). A distance of 0.5 specifies a swipe gesture with a distance that is half the screen
      # width or height.
      #
      # If distance is a value less than zero, then the distance of the swipe gesture will be half the height (vertical)
      # or width (horizontal) of the UI element being swiped. This is useful for preforming swipes/scrolls in vertical
      # or horizontal list objects.
      #
      # @param direction [Symbol] :up, :down, :left, or :right
      # @param distance [Float] scroll distance relative to the screen height or width
      # @example
      #   carousel_list.swipe_gesture(direction = :right, distance = 1)
      #
      def swipe_gesture(direction, distance = 0.5)
        raise 'Scroll distance must be less than 1' if distance > 1
        obj = element
        object_not_found_exception(obj)
        start_pt = [(obj.location.x + (obj.size.width * 0.5)).to_i, (obj.location.y + (obj.size.height * 0.5)).to_i]

        if distance < 0
          top = (start_pt[1] - obj.size.height).to_i
          bottom = (start_pt[1] + obj.size.height).to_i
          left = (start_pt[0] - obj.size.width).to_i
          right = (start_pt[0] + obj.size.width).to_i
        else
          screen_size = window_size
          top = (start_pt[1] - ((screen_size.height * distance) * 0.5)).to_i
          bottom = (start_pt[1] + ((screen_size.height * distance) * 0.5)).to_i
          left = (start_pt[0] - ((screen_size.width * distance) * 0.5)).to_i
          right = (start_pt[0] + ((screen_size.width * distance) * 0.5)).to_i
        end

        end_pt = case direction
                 when :up
                   [start_pt[0], bottom]
                 when :down
                   [start_pt[0], top]
                 when :left
                   [right, start_pt[1]]
                 when :right
                   [left, start_pt[1]]
                 end

        puts "Swipe start_pt = #{start_pt} / end_pt = #{end_pt}" if ENV['DEBUG']
        driver.action
              .click_and_hold(obj)
              .move_to_location(end_pt[0], end_pt[1], duration: 0.25)
              .pointer_up
              .perform
      end

      def element
        reset_mru_cache if @mru_app_session != Environ.app_session_id
        obj = if @context == :section
                parent_obj = nil
                parent_locator = @parent.get_locator

                if @mru_locator == @locator && @mru_parent == parent_locator && !@mru_object.nil?
                  return @mru_object
                end

                parent_locator.each do |locators|

                  if locators.keys[0] == :object
                    parent_obj = locators.values[0]
                    break
                  end

                  parent_obj = if parent_obj.nil?
                                 find_element(locators.keys[0], locators.values[0])
                               else
                                 parent_obj.find_element(locators.keys[0], locators.values[0])
                               end
                end
                puts "Found parent object '#{@parent.get_name}' - #{@parent.get_locator}" if ENV['DEBUG']
                parent_obj.find_element(@locator.keys[0], @locator.values[0])
              else
                return @mru_object if @mru_locator == @locator && !@mru_object.nil?
                find_element(@locator.keys[0], @locator.values[0])
              end
        puts "Found object '#{@name}' - #{@locator}" if ENV['DEBUG']
        @mru_object = obj
        @mru_locator = @locator
        @mru_parent = parent_locator
        @mru_app_session = Environ.app_session_id
        obj
      rescue
        puts "Did not find object '#{@name}' - #{@locator}" if ENV['DEBUG']
        nil
      end

      private

      def object_not_found_exception(obj)
        @type.nil? ? object_type = 'Object' : object_type = @type
        raise ObjectNotFoundError.new("#{object_type} named '#{@name}' (#{get_locator}) not found") unless obj
      end

      def object_ref_message
        "object '#{@name}' (#{get_locator})"
      end

      def compare(expected, actual)
        if expected.is_a?(Hash)
          result = false
          expected.each do |key, value|
            case key
            when :lt, :less_than
              result = actual < value
            when :lt_eq, :less_than_or_equal
              result = actual <= value
            when :gt, :greater_than
              result = actual > value
            when :gt_eq, :greater_than_or_equal
              result = actual >= value
            when :not_equal
              result = actual != value
            end
          end
        else
          result = expected == actual
        end
        result
      end
    end
  end
end
