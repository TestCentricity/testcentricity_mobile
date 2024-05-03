module TestCentricity
  module AppElements
    class AppRadio < AppUIElement
      def initialize(name, parent, locator, context)
        super
        @type = :radio
      end

      # Is radio selected?
      #
      # @return [Boolean]
      # @example
      #   unicode_radio.selected?
      #
      def selected?
        obj = element
        object_not_found_exception(obj)
        obj.selected?
      end

      # Set the selected state of a radio button object.
      #
      # @example
      #   unicode_radio.select
      #
      def select
        set_selected_state(true)
      end

      # Unselect a radio button object.
      #
      # @example
      #   unicode_radio.unselect
      #
      def unselect
        set_selected_state(false)
      end

      # Set the selected state of a radio button object.
      #
      # @param state [Boolean] true = selected / false = unselected
      # @example
      #   ascii_radio.set_selected_state(true)
      #
      def set_selected_state(state)
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
