module TestCentricity
  module AppElements
    class AppList < AppUIElement
      attr_accessor :list_item
      attr_accessor :scrolling
      attr_accessor :item_objects

      def initialize(name, parent, locator, context)
        super
        @type = :list
        @list_item = nil
        @scrolling = :vertical
        @item_objects = nil
      end

      def define_list_elements(element_spec)
        element_spec.each do |element, value|
          case element
          when :list_item
            @list_item = value
          when :scrolling
            @scrolling = value
          else
            raise "#{element} is not a recognized list element"
          end
        end
      end

      def scroll_mode
        obj = element
        object_not_found_exception(obj)
        @scrolling
      end

      def item_refs
        obj = element
        object_not_found_exception(obj)
        @item_objects
      end

      # Return the number of items in a list object.
      #
      # @return [Integer]
      # @example
      #   num_nav_items = nav_list.get_item_count
      #
      def get_item_count
        obj = element
        object_not_found_exception(obj)
        if Environ.is_ios? && obj.attribute(:type) == 'XCUIElementTypePickerWheel'
          raise 'This method is not supported for XCUIElementTypePickerWheel controls'
        end
        list_loc = get_list_item_locator
        items = obj.find_elements(list_loc.keys[0], list_loc.values[0])
        if items.size > 0 && Environ.is_android?
          start_count = items.count
          direction = @scrolling == :horizontal ? :right : :down
          scroll_count = 0
          loop do
            save_count = items.count
            swipe_gesture(direction)
            scroll_count += 1
            obj.find_elements(list_loc.keys[0], list_loc.values[0]).each do |item|
              items.push(item) unless items.include?(item)
            end
            break if items.count == save_count
          end
          direction = @scrolling == :horizontal ? :left : :up
          scroll_count.times do
            swipe_gesture(direction)
          end
        end
        @item_objects = items if Environ.is_android? && start_count < items.count
        items.count
      end

      # Return array of strings of all items in a list object.
      #
      # @return [Array]
      # @example
      #   nav_items = nav_list.get_options
      #
      def get_list_items
        list_items = []
        obj = element
        object_not_found_exception(obj)
        if Environ.is_ios? && obj.attribute(:type) == 'XCUIElementTypePickerWheel'
          raise 'This method is not supported for XCUIElementTypePickerWheel controls'
        end
        list_loc = get_list_item_locator
        items = obj.find_elements(list_loc.keys[0], list_loc.values[0])
        items.each do |item|
          list_items.push(item.text)
        end
        list_items
      end

      # Select the specified item in a list object. Accepts a String or Integer.
      #
      # @param item [String, Integer] text or index of item to select
      #
      # @example
      #   province_list.choose_item(2)
      #   province_list.choose_item('Manitoba')
      #
      def choose_item(item)
        obj = element
        object_not_found_exception(obj)
        if Environ.is_ios? && obj.attribute(:type) == 'XCUIElementTypePickerWheel'
          obj.send_keys(item)
        else
          list_loc = get_list_item_locator
          items = obj.find_elements(list_loc.keys[0], list_loc.values[0])
          if item.is_a?(Integer)
            items[item - 1].click
          else
            items.each do |list_item|
              if list_item.text == item
                list_item.click
                break
              end
            end
          end
        end
      end

      # Wait until the list's item_count equals the specified value, or until the specified wait time has expired. If the
      # wait time is nil, then the wait time will be Environ.default_max_wait_time.
      #
      # @param value [Integer or Hash] value expected or comparison hash
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   search_results_list.wait_until_item_count_is(10, 15)
      #     or
      #   search_results_list.wait_until_item_count_is({ :greater_than_or_equal => 1 }, 5)
      #
      def wait_until_item_count_is(value, seconds = nil)
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until { compare(value, get_item_count) }
      rescue
        raise "Value of List #{object_ref_message} failed to equal '#{value}' after #{timeout} seconds" unless get_item_count == value
      end

      # Wait until the list's item_count changes, or until the specified wait time has expired. If the wait time is nil,
      # then the wait time will be Environ.default_max_wait_time.
      #
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   search_results_list.wait_until_item_count_changes(10)
      #
      def wait_until_item_count_changes(seconds = nil)
        value = get_item_count
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until { get_item_count != value }
      rescue
        raise "Value of List #{object_ref_message} failed to change from '#{value}' after #{timeout} seconds" if get_item_count == value
      end

      private

      def get_list_item_locator
        if @list_item.nil?
          if Environ.device_os == :ios
            define_list_elements({ :list_item => { class: 'XCUIElementTypeCell' } } )
          else
            define_list_elements({ :list_item => { class: 'android.widget.FrameLayout' } } )
          end
        end
        @list_item
      end
    end
  end
end
