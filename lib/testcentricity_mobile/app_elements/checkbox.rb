module TestCentricity
  module AppElements
    class AppCheckBox < AppUIElement
      def initialize(name, parent, locator, context)
        super
        @type  = :checkbox
      end

      # Is checkbox checked?
      #
      # @return [Boolean]
      # @example
      #   remember_me_checkbox.checked?
      #
      def checked?
        obj = element
        object_not_found_exception(obj)
        obj.selected?
      end

      # Set the check state of a checkbox object.
      #
      # @example
      #   remember_me_checkbox.check
      #
      def check
        set_checkbox_state(true)
      end

      # Uncheck a checkbox object.
      #
      # @example
      #   remember_me_checkbox.uncheck
      #
      def uncheck
        set_checkbox_state(false)
      end

      # Set the check state of a checkbox object.
      #
      # @param state [Boolean] true = checked / false = unchecked
      # @example
      #   remember_me_checkbox.set_checkbox_state(true)
      #
      def set_checkbox_state(state)
        obj = element
        object_not_found_exception(obj)
        if state
          obj.click unless obj.selected?
        else
          obj.click if obj.selected?
        end
      end
    end
  end
end
