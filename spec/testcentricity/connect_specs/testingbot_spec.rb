# frozen_string_literal: true

describe TestCentricity::AppiumConnect, testingbot: true do
  include_context 'cloud_credentials'

  before(:context) do
    # instantiate React Native Demo test environment
    @environs ||= EnvironData
    @environs.find_environ('RN_DEMO', :yaml)
    # load cloud services credentials into environment variables
    load_cloud_credentials
    # specify generic browser config environment variables
    ENV['DRIVER'] = 'testingbot'
    ENV['AUTOMATE_PROJECT'] = 'TestCentricity Mobile - TestingBot'
    ENV['TEST_CONTEXT'] = 'RSpec - Environment Variables'
    ENV['DEVICE_TYPE'] = 'phone'
    # ENV['UPLOAD_APP'] = 'true'
  end

  describe 'Connect to TestingBot hosted mobile device simulator using W3C desired_capabilities hash' do
    context 'Mobile iOS device' do
      let(:ios_caps) {
        {
          driver: :testingbot,
          device_type: :phone,
          endpoint: "https://#{ENV['TB_USERNAME']}:#{ENV['TB_AUTHKEY']}@hub.testingbot.com/wd/hub",
          capabilities: {
            platformName: 'ios',
            'appium:platformVersion': '16.0',
            'appium:deviceName': 'iPhone 13',
            'appium:realDevice': true,
            'appium:automationName': 'XCUITest',
            'appium:app': 'tb://rndemoappios',
            'tb:options': {
              name: ENV['AUTOMATE_PROJECT'],
              build: 'RSpec - DesiredCaps Hash',
              appiumVersion: '2.10.3'
            }
          }
        }
      }

      it 'connects to iOS iPhone device using desired_capabilities hash' do
        AppiumConnect.initialize_appium(ios_caps)

        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :ios,
          os_version = '16.0',
          dev_name = 'iPhone 13',
          platform = :device
        )
      end
    end

    context 'Mobile Android device simulator' do
      let(:android_caps) {
        {
          driver: :testingbot,
          device_type: :phone,
          endpoint: "https://#{ENV['TB_USERNAME']}:#{ENV['TB_AUTHKEY']}@hub.testingbot.com/wd/hub",
          capabilities: {
            platformName: 'android',
            'appium:platformVersion': '12.0',
            'appium:deviceName': 'Pixel 6',
            'appium:automationName': 'UiAutomator2',
            'appium:app': 'tb://rndemoappandroid',
            'tb:options': {
              name: ENV['AUTOMATE_PROJECT'],
              build: 'RSpec - DesiredCaps Hash',
              appiumVersion: '2.10.3'
            }
          }
        }
      }

      it 'connects to Android phone device using desired_capabilities hash' do
        AppiumConnect.initialize_appium(android_caps)

        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :android,
          os_version = '12.0',
          dev_name = 'Pixel 6',
          platform = :simulator
        )
      end
    end
  end

  describe 'Connect to TestingBot hosted mobile device simulator using environment variables' do
    it 'connects to iOS iPhone device using environment variables' do
      ENV['TB_OS'] = 'iOS'
      ENV['TB_OS_VERSION'] = '16.0'
      ENV['TB_DEVICE'] = 'iPhone 13'
      ENV['REAL_DEVICE'] = 'true'
      ENV['AUTOMATION_ENGINE'] = 'XCUITest'
      ENV['APP'] = 'tb://RNDemoAppiOS'
      AppiumConnect.initialize_appium

      verify_mobile_connect(
        dev_type = :phone,
        dev_os = :ios,
        os_version = '16.0',
        dev_name = 'iPhone 13',
        platform = :device
      )
    end

    it 'connects to Android phone device using environment variables' do
      ENV['TB_OS'] = 'android'
      ENV['TB_OS_VERSION'] = '12.0'
      ENV['TB_DEVICE'] = 'Pixel 6'
      ENV['REAL_DEVICE'] = 'false'
      ENV['AUTOMATION_ENGINE'] = 'UiAutomator2'
      ENV['APP'] = 'tb://RNDemoAppAndroid'
      AppiumConnect.initialize_appium

      verify_mobile_connect(
        dev_type = :phone,
        dev_os = :android,
        os_version = '12.0',
        dev_name = 'Pixel 6',
        platform = :simulator
      )
    end
  end

  def verify_mobile_connect(dev_type, dev_os, os_version, dev_name, platform)
    # verify Environs are correctly set
    expect(Environ.driver).to eq(:testingbot)
    expect(Environ.platform).to eq(:mobile)
    expect(Environ.device).to eq(platform)
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
    driver_name = "testingbot_#{Environ.device_os}_#{Environ.device_type}".downcase.to_sym
    expect(Environ.driver_name).to eq(driver_name)
  end

  after(:each) do
    AppiumConnect.quit_driver
  end
end
