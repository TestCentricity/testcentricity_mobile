module TestCentricity
  module AppElements
    class AppSwitch < AppUIElement
      def initialize(name, parent, locator, context)
        super
        @type = :switch
      end

      # Is switch in ON state?
      #
      # @return [Boolean]
      # @example
      #   use_face_id_switch.on?
      #
      def on?
        obj = element
        object_not_found_exception(obj)

        if Environ.is_ios?
          state =  obj.attribute(:value)
          state.to_bool
        else
          state = obj.attribute(:checked)
          state.boolean? ? state : state == 'true'
        end
      end

      alias checked? on?
      alias selected? on?

      # Set the state of a switch object to ON.
      #
      # @example
      #   use_face_id_switch.on
      #
      def on
        obj = element
        object_not_found_exception(obj)
        obj.click unless on?
      end

      # Set the state of a switch object to OFF.
      #
      # @example
      #   use_face_id_switch.off
      #
      def off
        obj = element
        object_not_found_exception(obj)
        obj.click if on?
      end

      # Set the ON/OFF state of a switch object.
      #
      # @param state [Boolean] true = on / false = off
      # @example
      #   use_face_id_switch.set_switch_state(true)
      #
      def set_switch_state(state)
        obj = element
        object_not_found_exception(obj)
        state ? on : off
      end
    end
  end
end
