module TestCentricity
  module AppElements
    class AppImage < AppUIElement
      def initialize(name, parent, locator, context)
        super
        @type = :image
      end
    end
  end
end
