# frozen_string_literal: true

require 'parallel_tests'
require 'require_all'
require 'simplecov'
require 'testcentricity_mobile'

include TestCentricity
include Test::Unit::Assertions

SimpleCov.command_name("Features-#{ENV['PLATFORM']}-#{Time.now.strftime('%Y%m%d%H%M%S%L')}")
SimpleCov.merge_timeout 7200


require_relative 'world_data'
require_relative 'world_screens'
require_rel 'cloud_credentials'

require_rel 'data'
require_rel 'shared_components'

# conditionally require screen and section objects based on target platform
case ENV['PLATFORM'].downcase.to_sym
when :ios
  require_rel 'ios'
when :android
  require_rel 'android'
else
  raise "Platform unknown. Please specify the target test platform using '-p ios' or'-p android' in the command line"
end

$LOAD_PATH << './lib'

# set the default locale and auto load all translations from config/locales/*.rb,yml.
ENV['LOCALE'] = 'en-US' unless ENV['LOCALE']
ENV['LANGUAGE'] = 'en' unless ENV['LANGUAGE']
I18n.load_path += Dir['config/locales/*.{rb,yml}']
I18n.default_locale = ENV['LOCALE']
I18n.locale = ENV['LOCALE']
Faker::Config.locale = ENV['LOCALE']

# load cloud services credentials into environment variables
load_cloud_credentials
# instantiate all data objects and target test environment
include WorldData
ENV['DATA_SOURCE'] = 'yaml' unless ENV['DATA_SOURCE']
environs.find_environ(ENV['TEST_ENVIRONMENT'], ENV['DATA_SOURCE'].downcase.to_sym)
WorldData.instantiate_data_objects

# instantiate all screen objects
include WorldScreens
WorldScreens.instantiate_screen_objects

# set TestCentricity's default max wait time to 10 seconds
Environ.default_max_wait_time = 10
