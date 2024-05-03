require 'test/unit'

module TestCentricity
  class BaseScreenSectionObject
    # Define a trait for this screen or section object.
    #
    # Refer to the `Adding Traits to your ScreenObject` and `Adding Traits to a ScreenSection` sections of the ruby docs
    # for this gem.
    #
    # @param trait_name [Symbol] name of trait (as a symbol)
    # @param block [&block] trait value
    # @example
    #   trait(:screen_name)     { 'Shopping Basket' }
    #   trait(:screen_locator)  { accessibility_id: 'My Contacts View' }
    #   trait(:deep_link)       { 'geo-locations' }
    #   trait(:section_name)    { 'Cart List Item' }
    #   trait(:section_locator) { xpath: '(//XCUIElementTypeOther[@name="product row"])' }
    #
    def self.trait(trait_name, &block)
      define_method(trait_name.to_s, &block)
    end

    # Populate the specified UI elements on this screen or section object with the associated data from a Hash passed as
    # an argument. Data values must be in the form of a String for textfield controls. For checkboxes,radios, and switches,
    # data must either be a Boolean or a String that evaluates to a Boolean value (Yes, No, 1, 0, true, false). For screen
    # section objects, data values must be a String, and the screen section object must have a set method defined.
    #
    # The optional wait_time parameter is used to specify the time (in seconds) to wait for each UI element to become
    # visible before entering the associated data value. This option is useful in situations where entering data, or
    # setting the state of a UI element might cause other UI elements to become visible or active. Specifying a wait_time
    # value ensures that the subsequent UI elements will be ready to be interacted with as states are changed. If the wait
    # time is nil, then the wait time will be 5 seconds.
    #
    # To delete all text content in a text field, pass !DELETE as the data to be entered.
    #
    # If any of the specified UI elements are not currently visible, an attempt will be made to scroll the object in view.
    #
    # Refer to the `Populating your ScreenObject or ScreenSection with data` section of the ruby docs for this gem.
    #
    # @param data [Hash] UI element(s) and associated data to be entered
    # @param wait_time [Integer] wait time in seconds
    # @example
    #     fields = {
    #       payee_name_field => UserData.current.cardholder_name,
    #       card_number_field => UserData.current.card_num,
    #       expiration_field => UserData.current.expiry,
    #       security_code_field => UserData.current.cvv
    #     }
    #     populate_data_fields(fields)
    def populate_data_fields(data, wait_time = nil)
      timeout = wait_time.nil? ? 2 : wait_time
      data.each do |data_field, data_param|
        unless data_param.blank?
          # make sure the intended UI target element is visible before trying to set its value
          data_field.scroll_into_view unless data_field.wait_until_visible(timeout, post_exception = false)
          if data_param == '!DELETE'
            data_field.clear
          else
            case data_field.get_object_type
            when :checkbox
              data_field.set_checkbox_state(data_param.to_bool)
            when :radio
              data_field.set_selected_state(data_param.to_bool)
            when :textfield
              data_field.clear
              data_field.set(data_param)
            end
          end
        end
      end
    end

    # Verify one or more properties of one or more UI elements on a ScreenObject or ScreenSection. This method accepts
    # a hash containing key/hash pairs of UI elements and their properties or attributes to be verified.
    #
    # Refer to the `Verifying AppUIElements on your ScreenObject or ScreenSection` section of the ruby docs for this gem.
    #
    # @param ui_states [Hash] UI element(s) and associated properties to be validated
    # @param auto_scroll [Boolean] automatically scroll UI elements that are expected to be visible into view (default = true)
    #
    def verify_ui_states(ui_states, auto_scroll = true)
      ui_states.each do |ui_object, object_states|
        object_states.each do |property, state|
          actual = case property
                   when :visible
                    if auto_scroll && state
                      ui_object.scroll_into_view if ui_object.hidden?
                     end
                     ui_object.visible?
                   when :class
                     ui_object.get_attribute(:class)
                   when :exists
                     ui_object.exists?
                   when :enabled
                     ui_object.enabled?
                   when :disabled
                     ui_object.disabled?
                   when :hidden
                     ui_object.hidden?
                   when :checked
                     ui_object.checked?
                   when :selected
                     ui_object.selected?
                   when :value
                     ui_object.get_value
                   when :caption
                     ui_object.get_caption
                   when :placeholder
                     ui_object.get_placeholder
                   when :readonly
                     ui_object.read_only?
                   when :maxlength
                     ui_object.get_max_length
                   when :items
                     ui_object.get_list_items
                   when :itemcount
                     ui_object.get_item_count
                   when :width
                     ui_object.width
                   when :height
                     ui_object.height
                   when :x
                     ui_object.x_loc
                   when :y
                     ui_object.y_loc
                   when :count
                     ui_object.count
                   when :buttons
                     ui_object.buttons
                   else
                     raise "#{property} is not a valid property"
                   end
          error_msg = "Expected UI object '#{ui_object.get_name}' (#{ui_object.get_locator}) #{property} property to"
          ExceptionQueue.enqueue_comparison(ui_object, state, actual, error_msg)
        end
      end
    rescue ObjectNotFoundError => e
      ExceptionQueue.enqueue_exception(e.message)
    ensure
      ExceptionQueue.post_exceptions
    end

    # Perform a swipe gesture in the specified direction. The swipe start point is the center of the screen, and the
    # swipe end point is the distance specified. A distance of 1 specifies a swipe gesture with a distance that is the
    # full screen height (vertical swipe), or full screen width (horizontal swipe). A distance of 0.5 specifies a swipe
    # gesture with a distance that is half the screen width or height.
    #
    # @param direction [Symbol] :up, :down, :left, or :right
    # @param distance [Float] scroll distance relative to the screen height or width
    # @example
    #   swipe_gesture(direction = :down, distance = 1)
    #
    def swipe_gesture(direction, distance = 0.5)
      raise 'Scroll distance must be between 0 and 1' if (distance < 0 || distance > 1)
      size = window_size
      mid_pt = [(size.width * 0.5).to_i, (size.height * 0.5).to_i]
      top = (mid_pt[1] - ((size.height * distance) * 0.5)).to_i
      bottom = (mid_pt[1] + ((size.height * distance) * 0.5)).to_i
      left = (mid_pt[0] - ((size.width * distance) * 0.5)).to_i
      right = (mid_pt[0] + ((size.width * distance) * 0.5)).to_i

      case direction
      when :up
        start_pt = [mid_pt[0], top]
        end_pt = [mid_pt[0], bottom]
      when :down
        start_pt = [mid_pt[0], bottom]
        end_pt = [mid_pt[0], top]
      when :left
        start_pt = [left, mid_pt[1]]
        end_pt = [right, mid_pt[1]]
      when :right
        start_pt = [right, mid_pt[1]]
        end_pt = [left, mid_pt[1]]
      end

      puts "Swipe start_pt = #{start_pt} / end_pt = #{end_pt}" if ENV['DEBUG']
      driver.action
            .move_to_location(start_pt[0], start_pt[1])
            .pointer_down
            .move_to_location(end_pt[0], end_pt[1], duration: 0.25)
            .release
            .perform
    end
  end
end
