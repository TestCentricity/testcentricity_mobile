# frozen_string_literal: true

RSpec.describe TestCentricity::AppiumConnect, custom: true do
  include_context 'cloud_credentials'

  before(:context) do
    # instantiate React Native Demo test environment
    @environs ||= EnvironData
    @environs.find_environ('RN_DEMO', :yaml)
    # load cloud services credentials into environment variables
    load_cloud_credentials
    ENV['AUTOMATE_PROJECT'] = 'TestCentricity Mobile - BrowserStack'
    ENV['AUTOMATE_BUILD'] = "Version #{TestCentricityMobile::VERSION}"
  end

  context 'Connect to user-defined cloud hosting service using W3C desired_capabilities hash' do
    it 'raises exception when no capabilities are defined' do
      options = {
        driver: :custom,
        driver_name: :custom_no_caps,
        device_type: :phone,
        endpoint: "https://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub-cloud.browserstack.com/wd/hub"
      }
      expect { AppiumConnect.initialize_appium(options) }.to raise_error('User-defined cloud driver requires that you provide capabilities')
    end

    it 'raises exception when no endpoint is defined' do
      options = {
        driver: :custom,
        driver_name: :custom_no_endpoint,
        device_type: :phone,
        capabilities: {
          platformName: 'ios',
          'appium:platformVersion': '17',
          'appium:deviceName': 'iPhone 15 Pro Max',
          'appium:automationName': 'XCUITest',
          'appium:app': 'bs://53e07bec95a070602ff40c009a8bf85e5d378dfb',
          'bstack:options': {
            userName: ENV['BS_USERNAME'],
            accessKey: ENV['BS_AUTHKEY'],
            projectName: ENV['AUTOMATE_PROJECT'],
            buildName: ENV['AUTOMATE_BUILD'],
            sessionName: 'RSpec - DesiredCaps Hash',
            appiumVersion: '2.4.1'
          }
        }
      }
      expect { AppiumConnect.initialize_appium(options) }.to raise_error('User-defined cloud driver requires that you provide an endpoint')
    end

    it 'connects to an iPhone on BrowserStack' do
      Environ.platform = :mobile
      Environ.device = :device
      Environ.device_os = :ios
      options = {
        driver: :custom,
        device_type: :phone,
        endpoint: "https://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub-cloud.browserstack.com/wd/hub",
        capabilities: {
          platformName: 'ios',
          'appium:platformVersion': '17',
          'appium:deviceName': 'iPhone 15 Pro Max',
          'appium:automationName': 'XCUITest',
          'appium:app': 'RNDemoAppiOS',
          'bstack:options': {
            userName: ENV['BS_USERNAME'],
            accessKey: ENV['BS_AUTHKEY'],
            projectName: 'TestCentricity Mobile - BrowserStack',
            buildName: "Version #{TestCentricityMobile::VERSION}",
            sessionName: 'RSpec - Custom Driver Specs',
            appiumVersion: '2.4.1'
          }
        }
      }
      AppiumConnect.initialize_appium(options)

      verify_mobile_connect(
        dev_type = :phone,
        dev_os = :ios,
        os_version = '17',
        dev_name = 'iPhone 15 Pro Max'
      )
    end
  end

  def verify_mobile_connect(dev_type, dev_os, os_version, dev_name)
    # verify Environs are correctly set
    expect(Environ.driver).to eq(:custom)
    expect(Environ.platform).to eq(:mobile)
    expect(Environ.device_type).to eq(dev_type)
    expect(Environ.device_os).to eq(dev_os)
    expect(Environ.device_name).to eq(dev_name)
    expect(Environ.device_os_version).to eq(os_version)
    expect(AppiumConnect.app_installed?).to eq(true)
    expect(AppiumConnect.app_state).to eq(:running_in_foreground)
    expect(AppiumConnect.orientation).to eq(:portrait)
    expect(AppiumConnect.current_context).to eq('NATIVE_APP')
    expect(AppiumConnect.available_contexts).to eq(['NATIVE_APP'])
    expect(AppiumConnect.is_webview?).to eq(false)
    expect(AppiumConnect.is_native_app?).to eq(true)
    if dev_os == :ios
      expect(Environ.is_ios?).to eq(true)
    else
      expect(Environ.is_android?).to eq(true)
    end
    driver_name = "custom_#{Environ.device_os}_#{Environ.device_type}".downcase.to_sym
    expect(Environ.driver_name).to eq(driver_name)
  end

  after(:each) do
    AppiumConnect.quit_driver
  end
end
