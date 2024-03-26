# frozen_string_literal: true

describe TestCentricity::AppiumConnect, browserstack: true do
  include_context 'cloud_credentials'

  before(:context) do
    # instantiate React Native Demo test environment
    @environs ||= EnvironData
    @environs.find_environ('RN_DEMO', :yaml)
    # load cloud services credentials into environment variables
    load_cloud_credentials
    # specify generic browser config environment variables
    ENV['DRIVER'] = 'browserstack'
    ENV['AUTOMATE_PROJECT'] = 'TestCentricity Mobile - BrowserStack'
    ENV['AUTOMATE_BUILD'] = "Version #{TestCentricityMobile::VERSION}"
    ENV['TEST_CONTEXT'] = 'RSpec - Environment Variables'
    ENV['DEVICE_TYPE'] = 'phone'
    # ENV['UPLOAD_APP'] = 'true'
  end

  describe 'Connect to BrowserStack hosted mobile device simulator using W3C desired_capabilities hash' do
    context 'Mobile iOS device' do
      let(:ios_caps) {
        {
          driver: :browserstack,
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
              projectName: ENV['AUTOMATE_PROJECT'],
              buildName: ENV['AUTOMATE_BUILD'],
              sessionName: 'RSpec - DesiredCaps Hash',
              appiumVersion: '2.4.1'
            },
            language: 'En',
            locale: 'en_AU'
          }
        }
      }

      it 'connects to iOS iPhone device using desired_capabilities hash' do
        AppiumConnect.initialize_appium(ios_caps)

        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :ios,
          os_version = '17',
          dev_name = 'iPhone 15 Pro Max'
        )
      end
    end

    context 'Mobile Android device simulator' do
      let(:android_caps) {
        {
          driver: :browserstack,
          device_type: :phone,
          endpoint: "https://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub-cloud.browserstack.com/wd/hub",
          capabilities: {
            platformName: 'android',
            'appium:platformVersion': '13.0',
            'appium:deviceName': 'Google Pixel 7 Pro',
            'appium:automationName': 'UIAutomator2',
            'appium:app': 'RNDemoAppAndroid',
            'bstack:options': {
              userName: ENV['BS_USERNAME'],
              accessKey: ENV['BS_AUTHKEY'],
              projectName: ENV['AUTOMATE_PROJECT'],
              buildName: ENV['AUTOMATE_BUILD'],
              sessionName: 'RSpec - DesiredCaps Hash',
              appiumVersion: '2.4.1'
            },
            language: 'En',
            locale: 'en_AU'
          }
        }
      }

      it 'connects to Android phone device using desired_capabilities hash' do
        AppiumConnect.initialize_appium(android_caps)

        verify_mobile_connect(
          dev_type = :phone,
          dev_os = :android,
          os_version = '13.0',
          dev_name = 'Google Pixel 7 Pro'
        )
      end
    end
  end

  describe 'Connect to BrowserStack hosted mobile device simulator using environment variables' do
    it 'connects to iOS iPhone device using environment variables' do
      ENV['BS_OS'] = 'ios'
      ENV['BS_OS_VERSION'] = '17'
      ENV['BS_DEVICE'] = 'iPhone 15 Pro Max'
      ENV['APP'] = 'RNDemoAppiOS'
      AppiumConnect.initialize_appium

      verify_mobile_connect(
        dev_type = :phone,
        dev_os = :ios,
        os_version = '17',
        dev_name = 'iPhone 15 Pro Max'
      )
    end

    it 'connects to Android phone device using environment variables' do
      ENV['BS_OS'] = 'android'
      ENV['BS_OS_VERSION'] = '13.0'
      ENV['BS_DEVICE'] = 'Google Pixel 7 Pro'
      ENV['APP'] = 'RNDemoAppAndroid'
      ENV['APPIUM_VERSION'] = '2.4.1'
      AppiumConnect.initialize_appium

      verify_mobile_connect(
        dev_type = :phone,
        dev_os = :android,
        os_version = '13.0',
        dev_name = 'Google Pixel 7 Pro'
      )
    end
  end

  def verify_mobile_connect(dev_type, dev_os, os_version, dev_name)
    # verify Environs are correctly set
    expect(Environ.driver).to eq(:browserstack)
    expect(Environ.platform).to eq(:mobile)
    expect(Environ.device).to eq(:device)
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
    driver_name = "browserstack_#{Environ.device_os}_#{Environ.device_type}".downcase.to_sym
    expect(Environ.driver_name).to eq(driver_name)
  end

  after(:each) do
      AppiumConnect.quit_driver
    end
end
