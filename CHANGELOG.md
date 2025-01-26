# CHANGELOG
All notable changes to this project will be documented in this file.


## [4.1.0] - 25-JAN-2025

### Changed

* Updated `selenium-webdriver` gem to version 4.28.0.
* Updated `appium_lib` gem to version 15.3.0.
* Updated `appium_lib_core` gem to version 9.5.0.
* Ruby version 3.1.0 or greater is now required.


## [4.0.14] - 04-NOV-2024

### Changed

* Updated `selenium-webdriver` gem to version 4.26.0.
* Updated `rexml` gem to latest version to address ReDoS vulnerability.


## [4.0.13] - 24-SEP-2024

### Changed

* Updated `selenium-webdriver` gem to version 4.25.0.


## [4.0.12] - 30-AUG-2024

### Changed

* Updated `selenium-webdriver` gem to version 4.24.0.


## [4.0.11] - 08-AUG-2024

### Changed

* Updated `appium_lib` gem to version 15.2.2.
* Updated `appium_lib_core` gem to version 9.2.1.


## [4.0.10] - 25-JULY-2024

### Changed

* Updated `selenium-webdriver` gem to version 4.23.0.
* Updated `appium_lib` gem to version 15.2.0.
* Updated `appium_lib_core` gem to version 9.2.0.


## [4.0.9] - 23-JUNE-2024

### Changed

* Updated `selenium-webdriver` gem to version 4.22.0.


## [4.0.8] - 03-JUNE-2024

### Fixed

* When testing using locally hosted iOS simulators or physical devices, and when not passing an options hash to specify 
desired capabilities, the `AppiumConnect.initialize_appium` method now correctly sets the following XCUItest capabilities:
  * `appium:webviewConnectTimeout` capability is now correctly specified as an `Integer`
  * `appium:maxTypingFrequency` set to 15 keystrokes per minute to resolve an issue where characters are intermittently
    dropped during text entry by `AppUIElement.set`, `AppUIElement.send_keys`, or `BaseScreenSectionObject.populate_data_fields`
    methods.
* `AppList.list_item` attribute now defaults to `XCUIElementTypeOther`class for iOS/iPadOS platform and `android.view.ViewGroup`
class for Android platform.

### Changed

* Updated `appium_lib` gem to version 15.1.0.
* Updated `appium_lib_core` gem to version 9.1.1.
* Updated `selenium-webdriver` gem to version 4.21.1.


## [4.0.7] - 05-MAY-2024

### Added
* Added support for radio buttons via the `AppRadio` UI element class and the following methods:
  * `ScreenObject.radio`
  * `ScreenObject.radios`
  * `ScreenSection.radio`
  * `ScreenSection.radios`
* `ScreenObject.populate_data_fields` and `ScreenSection.populate_data_fields` methods now support radio buttons.

### Changed

* Updated `selenium-webdriver` gem to version 4.20.1.
* Updated `appium_lib_core` gem to version 8.0.2.


## [4.0.6] - 02-MAY-2024

### Fixed

* `ScreenSection.find_section` is now able to find `ScreenSection` objects embedded within other `ScreenSections`.


## [4.0.5] - 29-APR-2024

### Fixed

* `ScreenSection.disabled?` no longer returns wrong values.


## [4.0.4] - 26-APR-2024

### Changed

* Updated `selenium-webdriver` gem to version 4.20.0.
* Updated `appium_lib` gem to version 15.0.0.
* Updated `appium_lib_core` gem to version 8.0.1.
* No longer using deprecated Appium `driver.keyboard_shown?` method.


## [4.0.3] - 05-APR-2024

### Fixed

* `AppiumConnect.initialize_appium`, `AppiumServer.start`, and `AppiumServer.running?` methods now support Appium version 2.x.
Backward compatibility with Appium version 1.x is provided if `APPIUM_SERVER_VERSION` Environment Variable is set to `1`.


## [4.0.2] - 27-MAR-2024

### Changed

* Updated `selenium-webdriver` gem to version 4.19.0.


## [4.0.0] - 26-MAR-2024

### Fixed
* `DataPresenter.initialize` no longer fails if `data` parameter is `nil`.
* `ScreenObject.load_screen` now supports deeplinks on iOS physical devices.

### Added
* Added support for specifying and connecting to mobile devices and simulators on unsupported cloud hosting services using
`custom` user-defined driver and capabilities.
* Added the following new gesture methods:
  * `AppUIElement.scroll_into_view`
  * `AppUIElement.drag_by`
  * `AppUIElement.drag_and_drop`
  * `AppUIElement.swipe_gesture`
  * `ScreenObject.swipe_gesture`
  * `ScreenSection.swipe_gesture`
  * `ScreenSection.scroll_into_view`
* Added `AppUIElement.count` method.
* Added `AppAlert.buttons` and `AppAlert.get_caption` methods.
* Added the following biometrics methods:
  * `AppiumConnect.is_biometric_enrolled?`
  * `AppiumConnect.set_biometric_enrollment`
  * `AppiumConnect.biometric_match`

### Changed
* `AppiumConnect.initialize_appium` method now accepts an optional `options` hash for specifying desired capabilities
  (using W3C protocol), driver, driver name, endpoint URL, global driver setting, and device type information.
* Updated `ScreenObject.verify_ui_states` and `ScreenSection.verify_ui_states` methods to support automatically scrolling
  to offscreen UI elements.
* All touch and gesture methods refactored to no longer depend on deprecated `TouchAction` and `MultiTouchAction` classes.
* Ruby version 3.0.0 or greater is now required.
* Updated `appium_lib` gem to version 14.0.0.
* Updated `selenium-webdriver` gem to version 4.18.1.

### Removed
* Support for test data assets stored in Excel `.xls` has been removed because `.xls` files cannot be properly tracked
  and diffed by source control tools like git.
* `ExcelData` and `ExcelDataSource` classes removed.
* Removed dependence on `spreadsheet` gem.
* Removed the following deprecated methods:
  * `AppiumConnect.switch_to_default_context`
  * `AppiumConnect.reset_app`
  * `AppiumConnect.launch_app`
  * `AppiumConnect.close_app`


## [3.1.1] - 04-AUGUST-2022

### Fixed
* `AppiumConnect.available_contexts` now correctly returns a list of native app and web contexts when testing hybrid apps 
with WebViews on iOS simulators.


## [3.1.0] - 02-AUGUST-2022

### Added
* The `DRIVER` Environment Variable is now used to specify the `appium`, `browserstack`, `saucelabs`, `testingbot`,
  or `lambdatest` driver.


## [3.0.6] - 21-JUNE-2022

### Fixed
* `AppButton.get_caption` correctly returns captions of React Native buttons on Android platform where button caption object
hierarchy is `//android.widget.Button/android.widget.ViewGroup/android.widget.TextView`.


## [3.0.5] - 12-JUNE-2022

### Fixed
* Fixed `gemspec` to no longer include specs and Cucumber tests as part of deployment package for the gem.


## [3.0.4] - 02-JUNE-2022

### Added
* Added `AppUIElement.wait_until_enabled` method.


## [3.0.3] - 30-MAY-2022

### Added
* Added `AppAlert.await_and_respond` method.


## [3.0.2] - 26-MAY-2022

### Fixed
* Added runtime dependencies `curb` and `json` to gemspec.
* Fixed CHANGELOG url in gemspec.


## [3.0.1] - 26-MAY-2022

### Added
* Added support for testing on cloud hosted iOS and Android simulators and real devices on BrowserStack, SauceLabs, and TestingBot services.
* `ScreenObject.load_page` method adds support for using deep links to directly load screens/pages of native apps.
* `AppiumConnect.upload_app` method adds support for uploading native apps to BrowserStack and TestingBot services prior to running tests.

### Changed
* Ruby version 2.7 or greater is required.
