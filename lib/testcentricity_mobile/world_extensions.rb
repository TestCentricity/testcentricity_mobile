module WorldData
  def environs
    @environs ||= TestCentricity::EnvironData
  end

  # instantiate and register all data objects specified in data_objects method
  #
  def instantiate_data_objects
    # return if data objects have already been instantiated and registered
    return if TestCentricity::DataManager.loaded?

    # instantiate all data objects
    @data = {}
    data_objects.each do |data_type, data_class|
      @data[data_type] = data_class.new unless @data.has_key?(data_type)
      # define data object accessor method
      define_method(data_type) do
        if instance_variable_defined?(:"@#{data_type}")
          instance_variable_get(:"@#{data_type}")
        else
          instance_variable_set(:"@#{data_type}", TestCentricity::DataManager.find_data_object(data_type))
        end
      end
    end
    # register all data objects with DataManager
    TestCentricity::DataManager.register_data_objects(@data)
  end
end


module WorldScreens
  # instantiate and register all screen objects specified in screen_objects method
  #
  def instantiate_screen_objects
    # return if screen objects have already been instantiated and registered
    return if TestCentricity::ScreenManager.loaded?

    # instantiate all screen objects
    @screens = {}
    screen_objects.each do |screen_object, screen_class|
      obj = screen_class.new
      @screens[screen_object] = obj unless @screens.has_key?(screen_object)
      screen_names = obj.screen_name
      screen_names = Array(screen_names) if screen_names.is_a? String
      screen_names.each do |name|
        screen_key = name.gsub(/\s+/, '').downcase.to_sym
        @screens[screen_key] = obj unless @screens.has_key?(screen_key)
      end
      # define screen object accessor method
      define_method(screen_object) do
        if instance_variable_defined?(:"@#{screen_object}")
          instance_variable_get(:"@#{screen_object}")
        else
          instance_variable_set(:"@#{screen_object}", TestCentricity::ScreenManager.find_screen(screen_object))
        end
      end
    end
    # register all screen objects with ScreenManager
    TestCentricity::ScreenManager.register_screen_objects(@screens)
  end
end
