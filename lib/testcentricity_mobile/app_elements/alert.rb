module TestCentricity
  module AppElements
    class AppAlert < AppUIElement
      def initialize(name, parent, locator, context)
        super
        @type = :alert
      end

      # Wait until the alert modal is visible, or until the specified wait time has expired. If the wait time is nil, then the
      # wait time will be Environ.default_max_wait_time. Unlike wait_until_visible or wait_until_exists, this method does not
      # raise an exception if the alert modal does not appear within the specified wait time.
      # Returns true if the alert modal is visible.
      #
      # @return [Integer]
      # @param seconds [Integer or Float] wait time in seconds
      # @example
      #   permissions_modal.await(2)
      #
      def await(seconds)
        timeout = seconds.nil? ? Environ.default_max_wait_time : seconds
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until do
          reset_mru_cache
          visible?
        end
        true
      rescue
        false
      end

      # Performs the action to required accept the currently visible alert modal. If the alert modal is still visible after
      # 5 seconds, an exception is raised.
      #
      # @example
      #   alert_modal.accept
      #
      def accept
        reset_mru_cache
        alert_accept
        wait_until_gone(seconds = 5, post_exception = false)
        if visible?
          alert_accept
          wait_until_gone(5)
        end
      end

      # Performs the action required dismiss the currently visible alert modal. If the alert modal is still visible after
      # 5 seconds, an exception is raised.
      #
      # @example
      #   alert_modal.dismiss
      #
      def dismiss
        reset_mru_cache
        alert_dismiss
        wait_until_gone(seconds = 5, post_exception = false)
        if visible?
          alert_dismiss
          wait_until_gone(5)
        end
      end

      #
      # @return [Integer]
      # @param action [Symbol or String] action to perform if alert modal is visible. Acceptable values are :allow, :accept, :dont_allow, or :dismiss
      # @param timeout [Integer or Float] wait time in seconds. Defaults to 2 if not specified
      # @param button_name [String] optional caption of button to tap associated with the specified action
      # @example
      #   alert_modal.await_and_respond(:dismiss)
      #        OR
      #   permissions_modal.await_and_respond(:accept, timeout = 1, button_name = 'Allow Once')
      #
      def await_and_respond(action, timeout = 2, button_name = nil)
        reset_mru_cache
        action = action.gsub(/\s+/, '_').downcase.to_sym if action.is_a?(String)
        if await(timeout)
          case action
          when :allow, :accept
            if button_name.nil?
              accept
            elsif Environ.is_ios?
              Environ.appium_driver.execute_script('mobile: alert', { action: 'accept', buttonLabel: button_name })
            else
              Environ.appium_driver.execute_script('mobile: acceptAlert', { buttonLabel: button_name })
            end
          when :dont_allow, :dismiss
            if button_name.nil?
              dismiss
            elsif Environ.is_ios?
              Environ.appium_driver.execute_script('mobile: alert', { action: 'dismiss', buttonLabel: button_name })
            else
              Environ.appium_driver.execute_script('mobile: dismissAlert', { buttonLabel: button_name })
            end
          else
            raise "#{action} is not a valid selector"
          end
          if Environ.is_ios? && await(1)
            case action
            when :allow, :accept
              accept
            when :dont_allow, :dismiss
              dismiss
            end
            if await(1)
              buttons = Environ.appium_driver.execute_script('mobile: alert', { action: 'getButtons' })
              raise "Could not perform #{action} action on active modal. Available modal buttons are #{buttons}"
            end
          end
          true
        else
          false
        end
      end

      def buttons
        if Environ.is_ios?
          Environ.appium_driver.execute_script('mobile: alert', { action: 'getButtons' })
        else
          obj = element
          object_not_found_exception(obj)
          captions = []
          labels = obj.find_elements(:class, 'android.widget.Button')
          labels.each do |label|
            captions.push(label.text)
          end
          captions
        end
      end

      def get_caption
        obj = element
        object_not_found_exception(obj)
        if Environ.is_ios?
          captions = []
          labels = obj.find_elements(:class, 'XCUIElementTypeStaticText')
          labels.each do |label|
            captions.push(label.text)
          end
          captions
        else
          title_obj = obj.find_element(:id, 'android:id/alertTitle')
          msg_obj = obj.find_element(:id, 'android:id/message')
          if msg_obj.nil?
            [title_obj.text]
          else
            [title_obj.text, msg_obj.text]
          end
        end
      end
    end
  end
end
