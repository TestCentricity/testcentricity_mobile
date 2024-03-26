module TestCentricity
  module AppElements
    class AppTextField < AppUIElement
      def initialize(name, parent, locator, context)
        super
        @type = :textfield
      end

      # Is text field set to read-only?
      #
      # @return [Boolean]
      # @example
      #   comments_field.read_only?
      #
      def read_only?
        obj = element
        object_not_found_exception(obj)
        !!obj.attribute('readonly')
      end

      # Return maxlength character count of a text field.
      #
      # @return [Integer]
      # @example
      #   max_num_chars = comments_field.get_max_length
      #
      def get_max_length
        obj = element
        object_not_found_exception(obj)
        max_length = obj.attribute('maxlength')
        max_length.to_i unless max_length.blank?
      end

      # Return placeholder text of a text field.
      #
      # @return [String]
      # @example
      #   placeholder_message = username_field.get_placeholder
      #
      def get_placeholder
        obj = element
        object_not_found_exception(obj)
        if AppiumConnect.is_webview?
          obj.attribute('placeholder')
        else
          obj.text
        end
      end
    end
  end
end
