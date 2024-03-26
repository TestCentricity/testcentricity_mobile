# TestCentricity™ Mobile

[![Gem Version](https://badge.fury.io/rb/testcentricity_mobile.svg)](https://badge.fury.io/rb/testcentricity_mobile)
[![License (3-Clause BSD)](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg?style=flat-square)](http://opensource.org/licenses/BSD-3-Clause)
![Gem Downloads](https://img.shields.io/gem/dt/testcentricity_mobile)
![Maintained](https://img.shields.io/badge/maintenance-actively--developed-brightgreen.svg)
[![Docs](https://img.shields.io/badge/docs-rubydoc-blue.svg)](http://www.rubydoc.info/gems/testcentricity_mobile)


The TestCentricity™ Mobile core framework for native mobile iOS and Android app testing implements a Screen Object Model
DSL for use with Cucumber (version 7.x or greater) and Appium. It also facilitates the configuration of the appropriate
Appium capabilities and driver required to establish a connection with locally or cloud hosted iOS and Android real devices
or simulators.

The TestCentricity™ Mobile gem supports automated testing of native iOS and Android apps running on the following mobile
test targets:
* locally hosted iOS device simulators or physical iOS devices (using Appium and XCode on macOS)
* locally hosted Android devices or Android Studio virtual device emulators (using Appium and Android Studio)
* cloud hosted physical devices and simulators from the following service:
    * [Browserstack](https://www.browserstack.com/list-of-browsers-and-platforms/app_automate)
    * [Sauce Labs](https://saucelabs.com/platform/mobile-testing)
    * [TestingBot](https://testingbot.com/mobile/realdevicetesting)


## What's New

A complete history of bug fixes and new features can be found in the {file:CHANGELOG.md CHANGELOG} file.

The RubyDocs for this gem can be found [here](https://www.rubydoc.info/gems/testcentricity_mobile/).


### Which gem should I use?

* The [TestCentricity **Mobile** gem](https://rubygems.org/gems/testcentricity_mobile) only supports testing of native iOS and Android mobile apps
* The [TestCentricity **Web** gem](https://rubygems.org/gems/testcentricity_web) only supports testing of web interfaces via desktop and mobile web browsers
* The TestCentricity gem supports testing of native mobile apps and/or web interfaces via desktop and mobile web browsers.

| Tested platforms                                   | TestCentricity Mobile | TestCentricity Web | TestCentricity |
|----------------------------------------------------|-----------------------|--------------------|----------------|
| Native mobile iOS and/or Android apps only         | Yes                   | No                 | No             |
| Desktop/mobile web browsers only                   | No                    | Yes                | No             |
| Native mobile apps and desktop/mobile web browsers | No                    | No                 | Yes            |


## Installation

TestCentricity Mobile version 3.0 and above requires Ruby 3.0.0 or later. To install the TestCentricity Mobile gem, add
this line to your automation project's Gemfile:

    gem 'testcentricity_mobile'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install testcentricity_mobile


---
## Setup
### Using Cucumber

If you are using Cucumber, you need to require the following in your `env.rb` file:
```ruby
    require 'testcentricity_mobile'
```

### Using RSpec

If you are using RSpec instead, you need to require the following in your `spec_helper.rb` file:
```ruby
    require 'testcentricity_mobile'
```

---
## ScreenObjects

The **Screen Object Model** is a test automation pattern that aims to create an abstraction of your native mobile app's
User Interface that can be used in tests. The **Screen** Object Model in native mobile app test automation is equivalent
to the **Page** Object Model in web user interface test automation.

A **Screen Object** is an object that represents a single screen in your AUT (Application Under Test). **Screen Objects**
encapsulate the implementation details of a mobile app screen and expose an API that supports interaction with, and validation
of the UI elements on the screen.

**Screen Objects** makes it easier to maintain automated tests because changes to screen UI elements are updated in only
one location - in the `ScreenObject` class definition. By adopting a **Screen Object Model**, Cucumber feature files and
step definitions are no longer required to hold specific information about a screen's UI objects, thus minimizing maintenance
requirements. If any element on, or property of a screen changes (text field attributes, button captions, element states,
etc.), maintenance is performed in the `ScreenObject` class definition only, typically with no need to update the affected
feature files, scenarios, or step definitions.


### Defining a ScreenObject

Your `ScreenObject` class definitions should be contained within individual `.rb` files in the `features/support/<platform>/screens`
folder of your test automation project, where `<platform>` is typically `ios` or `android`. For each screen in your app,
you will typically have to define two `ScreenObjects` - one for the iOS version of your app and the other for the Android
version of your app.

    my_automation_project
        ├── config
        ├── features
        │   ├── step_definitions
        │   ├── support
        │   │   ├── android
        |   |   |   └── screens
        │   │   ├── ios
        |   |   |   └── screens
        │   │   ├── env.rb
        │   │   └── hooks.rb
        ├── Gemfile
        └── README.md


You define a new `ScreenObject` as shown below:
```ruby
    class LoginScreen < TestCentricity::ScreenObject
    end


    class ProductsScreen < TestCentricity::ScreenObject
    end


    class CheckoutAddressScreen < TestCentricity::ScreenObject
    end
```

### Adding Traits to your ScreenObject

Native app screens typically have names associated with them. Screens also typically have a unique object or attribute
that, when present, indicates that the screen's contents have fully loaded.

The `screen_name` trait is registered with the `ScreenManager` object, which includes a `find_screen` method that takes a
screen name as a parameter and returns an instance of the associated `ScreenObject`. If you intend to use the `ScreenManager`,
you must define a`screen_name` trait for each `ScreenObject` to be registered.

The `screen_name` trait is usually a `String` value that represents the name of the screen that will be matched by the
`ScreenManager.find_screen` method. `screen_name` traits are case and white-space sensitive. For screens that may be
referenced with multiple names, the `screen_name` trait may also be an `Array` of `String` values representing those
screen names.

The `screen_locator` trait specifies a locator for a unique object that exists once the screen's contents have been fully
rendered. The `screen_locator` trait is a locator strategy that uniquely identifies the object. The `ScreenObject.verify_screen_exists`
method waits for the `screen_locator` trait to exist, and raises an exception if the wait time exceeds the `default_max_wait_time`.

A `deep_link` trait should be defined if a screen can be directly loaded using a deep link. Specifying a `deep_link` trait
is optional, as not all screens can be directly accessed via a deep link.

You define your screen's **Traits** as shown below:
```ruby
    class LoginScreen < TestCentricity::ScreenObject
      trait(:screen_name)    { 'Login' }
      trait(:screen_locator) { { accessibility_id: 'login screen' } }
      trait(:deep_link)      { 'mydemoapprn://login' }
    end


    class ProductsScreen < TestCentricity::ScreenObject
      trait(:screen_name)    { 'Products' }
      trait(:screen_locator) { { accessibility_id: 'products screen' } }
      trait(:deep_link)      { 'mydemoapprn://store-overview' }
    end


    class CheckoutAddressScreen < TestCentricity::ScreenObject
      trait(:screen_name)    { 'Checkout - Address' }
      trait(:screen_locator) { { accessibility_id: 'checkout address screen' } }
      trait(:deep_link)      { 'mydemoapprn://checkout-address' }
    end
```

### Adding UI Elements to your ScreenObject

Native app screens are made up of UI elements like text fields, check boxes, switches, lists, buttons, etc. **UI Elements**
are added to your `ScreenObject` class definition as shown below:
```ruby
    class LoginScreen < TestCentricity::ScreenObject
      trait(:screen_name)    { 'Login' }
      trait(:screen_locator) { { accessibility_id: 'login screen' } }
      trait(:deep_link)      { 'mydemoapprn://login' }
      
      # Login screen UI elements
      labels     username_label: { accessibility_id: 'Username'},
                 password_label: { xpath: '(//XCUIElementTypeStaticText[@name="Password"])[1]'},
                 username_error: { accessibility_id: 'Username-error-message' },
                 password_error: { accessibility_id: 'Password-error-message' },
                 generic_error:  { accessibility_id: 'generic-error-message' }
      textfields username_field: { accessibility_id: 'Username input field' },
                 password_field: { accessibility_id: 'Password input field' }
      button     :login_button,  { accessibility_id: 'Login button' }
    end


    class CheckoutAddressScreen < TestCentricity::ScreenObject
      trait(:screen_name)    { 'Checkout - Address' }
      trait(:screen_locator) { { accessibility_id: 'checkout address screen' } }
      trait(:deep_link)      { 'mydemoapprn://checkout-address' }
      
      # Checkout Address screen UI elements
      textfields fullname_field:     { accessibility_id: 'Full Name* input field' },
                 address1_field:     { accessibility_id: 'Address Line 1* input field' },
                 address2_field:     { accessibility_id: 'Address Line 2 input field' },
                 city_field:         { accessibility_id: 'City* input field' },
                 state_region_field: { accessibility_id: 'State/Region input field' },
                 zip_code_field:     { accessibility_id: 'Zip Code* input field' },
                 country_field:      { accessibility_id: 'Country* input field' }
      button     :to_payment_button, { accessibility_id: 'To Payment button' }
    end
```

### Adding Methods to your ScreenObject

It is good practice for your Cucumber step definitions to call high level methods in your your `ScreenObject` instead of
directly accessing and interacting with a screen object's UI elements. You can add high level methods to your `ScreenObject`
class definition for interacting with the UI to hide implementation details, as shown below:
```ruby
    class LoginScreen < TestCentricity::ScreenObject
      trait(:screen_name)    { 'Login' }
      trait(:screen_locator) { { accessibility_id: 'login screen' } }
      trait(:deep_link)      { 'mydemoapprn://login' }
      
      # Login screen UI elements
      labels     username_label: { accessibility_id: 'Username'},
                 password_label: { xpath: '(//XCUIElementTypeStaticText[@name="Password"])[1]'},
                 username_error: { accessibility_id: 'Username-error-message' },
                 password_error: { accessibility_id: 'Password-error-message' },
                 generic_error:  { accessibility_id: 'generic-error-message' }
      textfields username_field: { accessibility_id: 'Username input field' },
                 password_field: { accessibility_id: 'Password input field' }
      button     :login_button,  { accessibility_id: 'Login button' }

      def verify_screen_ui
        ui = {
          header_label   => { visible: true, caption: 'Login' },
          username_label => { visible: true, caption: 'Username' },
          username_field => { visible: true, enabled: true },
          password_label => { visible: true, caption: 'Password' },
          password_field => { visible: true, enabled: true },
          login_button   => { visible: true, enabled: true, caption: 'Login' }
        }
        verify_ui_states(ui)
      end
      
      def login(username, password)
        fields = {
          username_field => username,
          password_field => password
        }
        populate_data_fields(fields)
        login_button.tap
      end
      
      def verify_entry_error(reason)
        ui = case reason.gsub(/\s+/, '_').downcase.to_sym
             when :invalid_password, :invalid_user
               { generic_error => { visible: true, caption: 'Provided credentials do not match any user in this service.' } }
             when :locked_account
               { generic_error => { visible: true, caption: 'Sorry, this user has been locked out.' } }
             when :no_username
               { username_error => { visible: true, caption: 'Username is required' } }
             when :no_password
               { password_error => { visible: true, caption: 'Password is required' } }
             else
               raise "#{reason} is not a valid selector"
             end
        verify_ui_states(ui)
      end
    end
```

Once your `ScreenObject` has been instantiated, you can call your methods as shown below:
```ruby
    login_screen.login('snicklefritz', 'Pa55w0rd')
    login_screen.verify_entry_error('invalid user')
```

### Loading your App's ScreenObjects using Deeplinks

Users typically move between an app's screens (or a web portal's pages) by interacting with various navigation metaphors,
usually by tapping on buttons or links, or making selections from menu, grid, carousel, or list items. When testing web
interfaces using automated tests, time consuming interactions with the user interface can usually be reduced by using URLs
to quickly load pages without following a strict workflow.

Being able to use a combination of public or private APIs and URLs to bypass the time consuming interactions with a user
interface that may be undergoing refactoring during ongoing development (and which could lead to test failures due to bugs
in the new UI) can result in significant reduction in test execution time. While all UI interactions should be comprehensively
tested, most of the repetitive time intensive UI workflow interactions required to establish a stable base state for testing
downstream functionality can be avoided by leveraging testability "shortcuts" provided by your app's developers.

For example, in order to verify the functionality of finalizing the purchase of products via an ecommerce app or web portal,
a typical workflow might require a user to search for products to purchase, select product specific options (color, size,
quantity, etc.), add the products to a shopping cart, and log in to their account before they can finalize the purchase.
By utilizing developer provided APIs, URLs, or deeplinks, test execution time can be greatly reduced.

The `ScreenObject.load_screen` method is used to load a screen using its defined `deep_link` trait. When testing on physical
iOS devices running iOS/iPadOS versions earlier than version 16.4, deep links can only be opened by sending the deeplink URL
to the mobile Safari web browser, and then accepting the confirmation modal that pops up. The `load_screen` method handles
invoking deeplinks on Android and iOS/iPadOS simulators and physical devices.

Refer to the [Speeding Up Tests With Deep Links](https://appiumpro.com/editions/7-speeding-up-tests-with-deep-links) post on [AppiumPro](https://appiumpro.com/) for more information about deeplinks.


---
## ScreenSections

A `ScreenSection` is a collection of **UI Elements** that may appear in multiple locations on a screen, or on multiple
screens in an app. It is a collection of **UI Elements** that represent a conceptual area of functionality, like a menu,
a navigation bar, or a search capability. **UI Elements** and functional behavior are confined to the scope of a `ScreenSection`
object.

A `ScreenSection` may contain other `ScreenSection` objects.


### Defining a ScreenSection

Your `ScreenSection` class definitions should be contained within individual `.rb` files in the `features/support/<platform>/sections`
folder of your test automation project, where `<platform>` is typically `ios` or `android`. For each screen section in your
app, you will typically have to define two `ScreenSections` - one for your iOS app and the other for your Android app.

    my_automation_project
        ├── config
        ├── features
        │   ├── step_definitions
        │   ├── support
        │   │   ├── android
        |   |   |   ├── screens
        |   |   |   └── sections
        │   │   ├── ios
        |   |   |   ├── screens
        |   |   |   └── sections
        │   │   ├── env.rb
        │   │   └── hooks.rb
        ├── Gemfile
        └── README.md


You define a new `ScreenSection` as shown below:
```ruby
    class NavMenu < TestCentricity::ScreenSection
    end
```

### Adding Traits to a ScreenSection

A `ScreenSection` typically has a root node object that encapsulates a collection of `UIElements`. The `section_locator`
trait specifies the CSS or Xpath expression that uniquely identifies that root node object.

You define your section's **Traits** as shown below:
```ruby
    class NavMenu < TestCentricity::ScreenSection
      trait(:section_name)    { 'Nav Menu' }
      trait(:section_locator) { { xpath: '//XCUIElementTypeScrollView' } }
    end
```

### Adding UI Elements to your ScreenSection

A `ScreenSection` is typically made up of UI elements like text fields, check boxes, switches, lists, buttons, etc. **UI
Elements** are added to your `ScreenSection` class definition as shown below:
```ruby
    class NavMenu < TestCentricity::ScreenSection
      trait(:section_name)    { 'Nav Menu' }
      trait(:section_locator) { { xpath: '//XCUIElementTypeScrollView' } }

      # Nav Menu UI elements
      buttons close_button:        { accessibility_id: 'close menu' },
              webview_button:      { accessibility_id: 'menu item webview' },
              qr_code_button:      { accessibility_id: 'menu item qr code scanner' },
              geo_location_button: { accessibility_id: 'menu item geo location' },
              drawing_button:      { accessibility_id: 'menu item drawing' },
              report_a_bug_button: { accessibility_id: 'menu item report a bug' },
              about_button:        { accessibility_id: 'menu item about' },
              reset_app_button:    { accessibility_id: 'menu item reset app' },
              biometrics_button:   { accessibility_id: 'menu item biometrics' },
              log_in_button:       { accessibility_id: 'menu item log in' },
              log_out_button:      { accessibility_id: 'menu item log out' },
              api_calls_button:    { accessibility_id: 'menu item api calls' },
              sauce_video_button:  { accessibility_id: 'menu item sauce bot video' }
    end
```

### Adding Methods to your ScreenSection

You can add methods to your `ScreenSection` class definition, as shown below:
```ruby
    class NavMenu < TestCentricity::ScreenSection
      trait(:section_name)    { 'Nav Menu' }
      trait(:section_locator) { { xpath: '//XCUIElementTypeScrollView' } }

      # Nav Menu UI elements
      buttons close_button:        { accessibility_id: 'close menu' },
              webview_button:      { accessibility_id: 'menu item webview' },
              qr_code_button:      { accessibility_id: 'menu item qr code scanner' },
              geo_location_button: { accessibility_id: 'menu item geo location' },
              drawing_button:      { accessibility_id: 'menu item drawing' },
              report_a_bug_button: { accessibility_id: 'menu item report a bug' },
              about_button:        { accessibility_id: 'menu item about' },
              reset_app_button:    { accessibility_id: 'menu item reset app' },
              biometrics_button:   { accessibility_id: 'menu item biometrics' },
              log_in_button:       { accessibility_id: 'menu item log in' },
              log_out_button:      { accessibility_id: 'menu item log out' },
              api_calls_button:    { accessibility_id: 'menu item api calls' },
              sauce_video_button:  { accessibility_id: 'menu item sauce bot video' }

      def verify_ui
        ui = {
          self                => { visible: true },
          close_button        => { visible: true, enabled: true },
          webview_button      => { visible: true, enabled: true, caption: 'Webview' },
          qr_code_button      => { visible: true, enabled: true, caption: 'QR Code Scanner' },
          geo_location_button => { visible: true, enabled: true, caption: 'Geo Location' },
          drawing_button      => { visible: true, enabled: true, caption: 'Drawing' },
          report_a_bug_button => { visible: true, enabled: true, caption: 'Report A Bug' },
          about_button        => { visible: true, enabled: true, caption: 'About' },
          reset_app_button    => { visible: true, enabled: true, caption: 'Reset App State' },
          biometrics_button   => { visible: true, enabled: true, caption: 'FaceID' },
          log_in_button       => { visible: true, enabled: true, caption: 'Log In' },
          log_out_button      => { visible: true, enabled: true, caption: 'Log Out' },
          api_calls_button    => { visible: true, enabled: true, caption: 'Api Calls' },
          sauce_video_button  => { visible: true, enabled: true, caption: 'Sauce Bot Video' }
        }
        verify_ui_states(ui)
      end

      def close
        close_button.click
        self.wait_until_hidden(3)
      end

      def verify_closed
        ui = {
          self => { visible: true },
          close_button => { visible: false }
        }
        verify_ui_states(ui)
      end
    end
```

### Adding ScreenSections to your ScreenObject

You add a `ScreenSection` to its associated `ScreenObject` as shown below:
```ruby
    class BaseAppScreen < TestCentricity::ScreenObject
      # Base App screen UI elements
      label    :header_label, { accessibility_id: 'container header' }
      sections nav_bar:  NavBar,
               nav_menu: NavMenu
    end
```
Once your `ScreenObject` has been instantiated, you can call its `ScreenSection` methods as shown below:

    base_screen.nav_menu.verify_ui


---
## AppUIElements

Native app `ScreenObjects` and `ScreenSections` are typically made up of **UI Element** like text fields, switches, lists,
buttons, etc. **UI Elements** are declared and instantiated within the class definition of the `ScreenObject` or `ScreenSection`
in which they are contained. With TestCentricity, all native app screen UI elements are based on the `AppUIElement` class.


### Declaring and Instantiating AppUIElements

Single `AppUIElement` declarations have the following format:

    elementType :elementName, { locator_strategy: locator_identifier }

* The `elementName` is the unique name that you will use to refer to the UI element and is specified as a `Symbol`.
* The `locator_strategy` specifies the [selector strategy](https://appium.io/docs/en/commands/element/find-elements/index.html#selector-strategies) 
that Appium will use to find the `AppUIElement`. Valid selectors are `accessibility_id:`, `id:`, `name:`, `class:`, `xpath:`, 
`predicate:` (iOS only), `class_chain:` (iOS only), and `css:` (WebViews in hybrid apps only).
* The `locator_identifier` is the value or attribute that uniquely and unambiguously identifies the `AppUIElement`.

Multiple `AppUIElement` declarations for a collection of elements of the same type can be performed by passing a hash table
containing the names and locators of each individual element.

### Example AppUIElement Declarations

Supported `AppUIElement` elementTypes and their declarations have the following format:

*Single element declarations:*
```ruby
    class SampleScreen < TestCentricity::ScreenObject
      button     :button_name, { locator_strategy: locator_identifier }
      textfield  :field_name, { locator_strategy: locator_identifier }
      checkbox   :checkbox_name, { locator_strategy: locator_identifier }
      label      :label_name, { locator_strategy: locator_identifier }
      list       :list_name, { locator_strategy: locator_identifier }
      image      :image_name, { locator_strategy: locator_identifier }
      switch     :switch_name, { locator_strategy: locator_identifier }
      element    :element_name, { locator_strategy: locator_identifier }
      alert      :alert_name, { locator_strategy: locator_identifier }
    end
```
*Multiple element declarations:*
```ruby
    class SampleScreen < TestCentricity::ScreenObject
      buttons    button_1_name: { locator_strategy: locator_identifier },
                 button_2_name: { locator_strategy: locator_identifier },
                 button_X_name: { locator_strategy: locator_identifier }
      textfields field_1_name: { locator_strategy: locator_identifier },
                 field_2_name: { locator_strategy: locator_identifier },
                 field_X_name: { locator_strategy: locator_identifier }
      checkboxes check_1_name: { locator_strategy: locator_identifier },
                 check_2_name: { locator_strategy: locator_identifier },
                 check_X_name: { locator_strategy: locator_identifier }
      labels     label_1_name: { locator_strategy: locator_identifier },
                 label_X_name: { locator_strategy: locator_identifier }
      images     image_1_name: { locator_strategy: locator_identifier },
                 image_X_name: { locator_strategy: locator_identifier }
    end
```
Refer to the Class List documentation for the `ScreenObject` and `ScreenSection` classes for details on the class methods
used for declaring and instantiating `AppUIElements`. Examples of UI element declarations can be found in the ***Adding
UI Elements to your ScreenObject*** and ***Adding UI Elements to your ScreenSection*** sections above.


### AppUIElement Inherited Methods

With TestCentricity, all native app UI elements are based on the `AppUIElement` class, and inherit the following methods:

**Action methods:**

    element.click
    element.tap
    element.double_tap
    element.long_press
    element.scroll_into_view
    element.drag_by(right_offset, down_offset)
    element.drag_and_drop(target)
    element.swipe_gesture(direction, distance)

**Object state methods:**

    element.exists?
    element.visible?
    element.hidden?
    element.enabled?
    element.disabled?
    element.selected?
    element.tag_name
    element.width
    element.height
    element.x_loc
    element.y_loc
    element.count
    element.get_attribute(attrib)

**Waiting methods:**

    element.wait_until_exists(seconds)
    element.wait_until_gone(seconds)
    element.wait_until_visible(seconds)
    element.wait_until_hidden(seconds)
    element.wait_until_enabled(seconds)
    element.wait_until_value_is(value, seconds)
    element.wait_until_value_changes(seconds)


### Populating your ScreenObject or ScreenSection with data

A typical automated test may be required to perform the entry of test data by interacting with various `AppUIElements` on
your `ScreenObject` or `ScreenSection`. This data entry can be performed using the various object action methods (listed
above) for each `AppUIElement` that needs to be interacted with.

The `ScreenObject.populate_data_fields` and `ScreenSection.populate_data_fields` methods support the entry of test data
into a collection of `AppUIElements`. The `populate_data_fields` method accepts a hash containing key/hash pairs of
`AppUIElements` and their associated data to be entered. Data values must be in the form of a `String` for `textfield`
controls. For `checkbox` controls, data must either be a `Boolean` or a `String` that evaluates to a `Boolean` value (Yes,
No, 1, 0, true, false).

The `populate_data_fields` method verifies that data attributes associated with each `AppUIElement` is not `nil` or `empty`
before attempting to enter data into the `AppUIElement`.

The optional `wait_time` parameter is used to specify the time (in seconds) to wait for each `AppUIElement` to become
viable for data entry (the `AppUIElement` must be visible and enabled) before entering the associated data value. This
option is useful in situations where entering data, or setting the state of a `AppUIElement` might cause other `AppUIElements`
to become visible or active. Specifying a wait_time value ensures that the subsequent `AppUIElements` will be ready to
be interacted with as states are changed. If the wait time is `nil`, then the wait time will be 5 seconds.

If any of the specified UI elements are not currently visible, the `populate_data_fields` method will attempt to scroll
the UI object in view on the vertical axis (down, then up).
```ruby
    def enter_data(user_data)
      fields = {
        first_name_field   => user_data.first_name,
        last_name_field    => user_data.last_name,
        email_field        => user_data.email,
        phone_number_field => user_data.phone_number
      }
      populate_data_fields(fields, wait_time = 2)
    end
```

### Verifying AppUIElements on your ScreenObject or ScreenSection

A typical automated test executes one or more interactions with the user interface, and then performs a validation to
verify whether the expected state of the UI has been achieved. This verification can be performed using the various object
state methods(listed above) for each `AppUIElement` that requires verification. Depending on the complexity and number of
`AppUIElements` to be verified, the code required to verify the presence of `AppUIElements` and their correct states can
become cumbersome.

The `ScreenObject.verify_ui_states` and `ScreenSection.verify_ui_states` methods support the verification of multiple
properties of multiple UI elements on a `ScreenObject` or `ScreenSection`. The `verify_ui_states` method accepts a hash
containing key/hash pairs of UI elements and their properties or attributes to be verified.
```ruby
     ui = {
       object1 => { property: expected_state },
       object2 => { property1: expected_state, property2: expected_state },
       object3 => { property: expected_state }
     }
     verify_ui_states(ui)
```
The `verify_ui_states` method automatically scrolls UI elements that are expected to be visible into view. Auto-scrolling
only occurs on the vertical axis (down, then up). Setting the `auto_scroll` parameter to `false` prevents automatic scrolling
from occurring.

The `verify_ui_states` method queues up any exceptions that occur while verifying each object's properties until all
`AppUIElements`and their properties have been checked, and then posts any exceptions encountered upon completion. Posted
exceptions include a screenshot of the screen where expected results did not match actual results.

The `verify_ui_states` method supports the following property/state pairs:

**All Objects:**

    :exists     Boolean
    :enabled    Boolean
    :disabled   Boolean
    :visible    Boolean
    :hidden     Boolean
    :width      Integer
    :height     Integer
    :x          Integer
    :y          Integer
    :count      Integer
    :value      String
    :caption    String
    :attribute  Hash
    :class      String

**Text Fields:**

    :placeholder String
    :readonly    Boolean  (WebViews only)
    :maxlength   Integer  (WebViews only)

**Checkboxes and Switches:**

    :checked Boolean

#### Comparison States

The `verify_ui_states` method supports comparison states using property/comparison state pairs:

    object => { property: { comparison_state: value } }

Comparison States:

    :lt or :less_than                  Integer or String
    :lt_eq or :less_than_or_equal      Integer or String
    :gt or :greater_than               Integer or String
    :gt_eq or :greater_than_or_equal   Integer or String
    :starts_with                       String
    :ends_with                         String
    :contains                          String
    :not_contains or :does_not_contain Integer or String
    :not_equal                         Integer, String, or Boolean


#### I18n Translation Validation

The `verify_ui_states` method also supports I18n string translations using property/I18n key name pairs:

    object => { property: { translate_key: 'name of key in I18n compatible .yml file' } }

**I18n Translation Keys:**

    :translate            String
    :translate_upcase     String
    :translate_downcase   String
    :translate_capitalize String
    :translate_titlecase  String

The example below depicts the usage of the `verify_ui_states` method to verify that the captions for menu items are correctly
translated.
```ruby
    def verify_menu
      ui = {
        account_settings_item => {
          visible: true,
          caption: { translate: 'Settings.account' }
        },
        help_item => {
          visible: true,
          caption: { translate: 'Settings.help' }
        },
        feedback_item => {
          visible: true,
          caption: { translate: 'Settings.feedback' }
        },
        legal_item => {
          visible: true,
          caption: { translate: 'Settings.legal' }
        },
        configurations_item => {
          visible: true,
          caption: { translate: 'Settings.configurations' }
        },
        contact_us_item => {
          visible: true,
          caption: { translate: 'Settings.contact' }
        },
        sign_out_item => {
          visible: true,
          caption: { translate: 'Settings.sign_out' }
        }
      }
      verify_ui_states(ui)
    end
```
I18n `.yml` files contain key/value pairs representing the name of a translated string (key) and the string value. For the
menu example above, the translated strings for English, Spanish, and French are represented below:

**English** - `en.yml`
```yaml
    en:
      Settings:
        account: 'Account'
        help: 'Help'
        feedback: 'Feedback'
        legal: 'Legal'
        configurations: 'Configurations'
        contact: 'Contact'
        sign_out: 'Sign out'
```
**Spanish** - `es.yml`
```yaml
    es:
      Settings:
        account: 'Cuenta'
        help: 'Ayuda'
        feedback: 'Comentario'
        legal: 'Legal'
        configurations: 'Configuraciones'
        contact: 'Contacto'
        sign_out: 'Cerrar sesión'
```
**French** - `fr.yml`
```yaml
    fr:
      Settings:
        account: 'Compte'
        help: 'Aide'
        feedback: 'Retour'
        legal: 'Légal'
        configurations: 'Configurations'
        contact: 'Contact'
        sign_out: 'Fermer la session'
```

Each supported language/locale combination has a corresponding `.yml` file. I18n `.yml` file naming convention uses
[ISO-639 language codes and ISO-3166 country codes](https://docs.oracle.com/cd/E13214_01/wli/docs92/xref/xqisocodes.html).
For example:

| Language (Country)    | File name |
|-----------------------|-----------|
| English               | en.yml    |
| English (Canada)      | en-CA.yml |
| French (Canada)       | fr-CA.yml |
| French                | fr.yml    |
| Spanish               | es.yml    |
| German                | de.yml    |
| Portuguese (Brazil)   | pt-BR.yml |
| Portuguese (Portugal) | pt-PT.yml |

Baseline translation strings are stored in `.yml` files in the `config/locales/` folder.

    my_automation_project
        ├── config
        │   ├── locales
        │   │   ├── en.yml
        │   │   ├── es.yml
        │   │   ├── fr.yml
        │   │   ├── fr-CA.yml
        │   │   └── en-AU.yml
        │   ├── test_data
        │   └── cucumber.yml
        ├── features
        ├── Gemfile
        └── README.md


---
## Instantiating ScreenObjects and Utilizing the ScreenManager

Before you can call the methods in your `ScreenObjects` and `ScreenSections`, you must instantiate the `ScreenObjects` of
your native mobile application, as well as create instance variables which can be used when calling `ScreenObject` methods
from your step definitions or specs.

The `ScreenManager` class provides methods for supporting the instantiation and management of `ScreenObjects`. In the code
example below, the `screen_objects` method contains a hash table of your `ScreenObject` instances and their associated
`ScreenObject` classes to be instantiated by `ScreenManager`:
```ruby
    module WorldScreens
      def screen_objects
        {
          login_screen:            LoginScreen,
          registration_screen:     RegistrationScreen,
          search_results_screen:   SearchResultsScreen,
          products_grid_screen:    ProductsCollectionScreen,
          product_detail_screen:   ProductDetailScreen,
          shopping_basket_screen:  ShoppingBasketScreen,
          payment_method_screen:   PaymentMethodScreen,
          confirm_purchase_screen: PurchaseConfirmationScreen,
          my_account_screen:       MyAccountScreen,
          my_order_history_screen: MyOrderHistoryScreen
        }
      end
    end
    
    World(WorldScreens)
```

The `WorldScreens` module above should be defined in the `world_screens.rb` file in the `features/support` folder.

Include the code below in your `env.rb` file to ensure that your `ScreenObjects` are instantiated before your Cucumber
scenarios are executed:
```ruby
    include WorldScreens
    WorldPages.instantiate_screen_objects
```
**NOTE:** If you intend to use the `WorldScreens`, you must define a `screen_name` trait for each of the `ScreenObjects`
to be registered.


### Leveraging the ScreenManager in your Cucumber tests

Many Cucumber based automated tests suites include scenarios that verify that mobile app screens are correctly loaded,
displayed, or can be navigated to by clicking associated menus and navigation elements. One such Cucumber navigation
scenario is displayed below:
```gherkin
    Scenario Outline:  Verify screen navigation features
      Given I am on the Products screen
      When I tap the <screen_name> navigation menu item
      Then I expect the <screen_name> screen to be correctly displayed

      Examples:
        |screen_name      |
        |Registration     |
        |Shopping Basket  |
        |My Account       |
        |My Order History |
```
In the above example, the step definitions associated with the 3 steps can be implemented using the `ScreenManager.find_screen`
method to match the specified `screen_name` argument with the corresponding `ScreenObject` as shown below:
```ruby
    include TestCentricity

    When(/^I (?:load|am on) the (.*) screen$/) do |screen_name|
      # find and load the specified target screen
      target_screen = ScreenManager.find_screen(screen_name)
      target_screen.load_screen
    end
    
    
    When(/^I (?:click|tap) the ([^\"]*) navigation menu item$/) do |screen_name|
      # find and navigate to the specified target screen
      target_screen = ScreenManager.find_screen(screen_name)
      target_screen.navigate_to
    end
    
    
    Then(/^I expect the (.*) screen to be correctly displayed$/) do |screen_name|
      # find and verify that the specified target screen is loaded
      target_screen = ScreenManager.find_screen(screen_name)
      target_screen.verify_screen_exists
      # verify that target screen is correctly displayed
      target_screen.verify_screen_ui
    end
```

---
## Connecting to a Mobile Simulator or Device

The `AppiumConnect.initialize_appium` method configures the appropriate Appium capabilities required to establish a connection
with a locally or cloud hosted target iOS or Android simulator or real device.

Since its inception, TestCentricity has provided support for establishing a single connection to a target iOS or Android
simulator or real device by instantiating an Appium driver object. **Environment Variables** are used to specify the local
or remote cloud hosted target platform, and the various Appium capability parameters required to configure the driver object.
The appropriate **Environment Variables** are typically specified in the command line at runtime through the use of profiles
set in a `cucumber.yml` file (Refer to [**section 8.4 (Using Configuration Specific Profiles in `cucumber.yml`)**](#using-configuration-specific-profiles-in-cucumber-yml) below).

However, due to the growing number of optional Appium capabilities that are being offered by cloud hosted service providers
(like BrowserStack, Sauce Labs, TestingBot, or LambdaTest), **Environment Variables** may not effectively address.

Beginning with TestCentricity version 4.0.0, the `TestCentricity::AppiumConnect.initialize_appium` method accepts an optional
`options` hash for specifying desired capabilities (using the W3C protocol), driver type, driver name, endpoint URL, and
device type information.


### Specifying Options and Capabilities in the `options` Hash

For those test scenarios where cumbersome **Environment Variables** are less than ideal, call the `AppiumConnect.initialize_appium`
method with an `options` hash that specifies the Appium desired capabilities, the driver type, and the device type, as depicted
in the example below:
```ruby
    options = {
      driver: :appium,
      devicetype: :phone or :tablet,
      capabilities: {
        platformName: :ios or :android,
        'appium:platformVersion': os_version,
        'appium:deviceName': device_name,
        'appium:automationName': 'XCUITest' or 'UiAutomator2',
        'appium:app': path_to_app, }
    }
    AppiumConnect.initialize_appium(options)
```
Additional options that can be specified in an `options` hash include the following:

| Option           | Purpose                                                                        |
|------------------|--------------------------------------------------------------------------------|
| `driver_name:`   | optional driver name                                                           |
| `endpoint:`      | optional endpoint URL for local Appium server or cloud hosted service provider |
| `global_driver:` | define new driver with global scope if `true`                                  |


Details on specifying desired capabilities, driver type, endpoint URL, global driver scope, and default driver names are
provided in each of the platform hosting sections below.

#### Specifying the Driver Type

The `driver:` type is a required entry in the `options` hash when instantiating an Appium driver object using the
`initialize_appium` method. Valid `driver:` type values are listed in the table below:

| `driver:`       | **Driver Type**                                                       |
|-----------------|-----------------------------------------------------------------------|
| `:appium`       | locally hosted native iOS/Android device simulator or physical device |
| `:browserstack` | remote hosted on BrowserStack                                         |
| `:saucelabs`    | remote hosted on Sauce Labs                                           |
| `:testingbot`   | remote hosted on TestingBot                                           |
| `:custom`       | remote hosted on unsupported cloud based hosting services             |

#### Specifying a Driver Name

An optional user defined `driver_name:` can be specified in the `options` hash when instantiating an Appium driver object
using the `TestCentricity::AppiumConnect.initialize_appium` method. If a driver name is not specified, the `initialize_appium`
method will assign a default driver name comprised of the specified driver type (`driver:`) and the device OS and device
type specified in the `capabilities:` hash. Details on default driver names are provided in each of the device/simulator
hosting sections below.


### Connecting to Locally Hosted Simulators or Physical Devices

Refer to [this page](https://appium.io/docs/en/2.4/guides/caps/) for information regarding specifying Appium capabilities. The Appium server must be running prior
to invoking Cucumber to run your features/scenarios on locally hosted iOS or Android simulators or physical devices. Refer
to [**section 8.2.3 (Starting and Stopping Appium Server)**](#starting-and-stopping-appium-server) below.

#### Connecting to Locally Hosted iOS Simulators or Physical Devices

You can run your automated tests on locally hosted iOS simulators or physically connected devices using Appium and XCode
on macOS. You must install Appium, XCode, and the iOS version-specific device simulators for XCode. Information about
Appium setup and configuration requirements with the XCUITest driver for testing on physically connected iOS devices can
be found on [this page](https://github.com/appium/appium-xcuitest-driver/blob/master/docs/real-device-config.md). Refer to [this page](https://appium.github.io/appium-xcuitest-driver/5.12/capabilities/) for information regarding specifying Appium capabilities that are
specific to the XCUITest driver.

##### Local iOS Simulators or Physical Devices using Environment Variables

If the `options` hash is not provided when calling the `TestCentricity::AppiumConnect.initialize_appium` method, the following
**Environment Variables** must be set as described in the table below.

| **Environment Variable** | **Description**                                                                                                                                                       |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DRIVER`                 | Must be set to `appium`                                                                                                                                               |
| `APP_PLATFORM_NAME`      | Must be set to `iOS`                                                                                                                                                  |
| `AUTOMATION_ENGINE`      | Must be set to `XCUITest`                                                                                                                                             |
| `APP_VERSION`            | Must be set to `17.4`, `16.2`, or which ever iOS version you wish to run within the XCode Simulator                                                                   |
| `APP_DEVICE`             | Set to iOS device name supported by the iOS Simulator (`iPhone 13 Pro Max`, `iPad Pro (12.9-inch) (5th generation)`, etc.) or name of physically connected iOS device |
| `DEVICE_TYPE`            | Must be set to `phone` or `tablet`                                                                                                                                    |
| `APP`                    | Must be set to path where iOS app can be accessed and loaded                                                                                                          |
| `UDID`                   | UDID of physically connected iOS device (not used for simulators)                                                                                                     |
| `TEAM_ID`                | unique 10-character Apple developer team identifier string (not used for simulators)                                                                                  |
| `TEAM_NAME`              | String representing a signing certificate (not used for simulators)                                                                                                   |
| `APP_NO_RESET`           | [Optional] Don't reset app state after each test. Set to `true` or `false`                                                                                            |
| `APP_FULL_RESET`         | [Optional] Perform a complete reset. Set to `true` or `false`                                                                                                         |
| `WDA_LOCAL_PORT`         | [Optional] Used to forward traffic from Mac host to real iOS devices over USB. Default value is same as port number used by WDA on device.                            |
| `LOCALE`                 | [Optional] Locale to set for the simulator.  e.g.  `fr_CA`                                                                                                            |
| `LANGUAGE`               | [Optional] Language to set for the simulator.  e.g.  `fr`                                                                                                             |
| `ORIENTATION`            | [Optional] Set to `portrait` or `landscape` (only for iOS simulators)                                                                                                 |
| `NEW_COMMAND_TIMEOUT`    | [Optional] Time (in Seconds) that Appium will wait for a new command from the client                                                                                  |
| `SHOW_SIM_KEYBOARD`      | [Optional] Show the simulator keyboard during text entry. Set to `true` or `false`                                                                                    |
| `SHUTDOWN_OTHER_SIMS`    | [Optional] Close any other running simulators. Set to `true` or `false`. See note below.                                                                              |

The `SHUTDOWN_OTHER_SIMS` environment variable can only be set if you are running Appium Server with the `--relaxed-security`
or `--allow-insecure=shutdown_other_sims` arguments passed when starting it from the command line, or when running the server
from the Appium Server GUI app. A security violation error will occur without relaxed security enabled.

Refer to [**section 8.4 (Using Configuration Specific Profiles in `cucumber.yml`)**](#using-configuration-specific-profiles-in-cucumber-yml) below.


##### Local iOS Simulators or Physical Devices using the `options` Hash

When using the `options` hash, the following options and capabilities must be specified:
  - `driver:` must be set to `:appium`
  - `device_type:` must be set to `:tablet` or `:phone`
  - `platformName:` must be set to `ios` in the `capabilities:` hash
  - `'appium:automationName':` must be set to `xcuitest` in the `capabilities:` hash
  - `'appium:platformVersion':` must be set to the version of iOS on the simulator or physical device
  - `'appium:deviceName':` must be set to the name of the iOS simulator or physical device
  - `'appium:app'`: must be set to path where iOS app can be accessed and loaded

```ruby
    options = {
      driver: :appium,
      device_type: phone_or_tablet,
      capabilities: {
        platformName: :ios,
        'appium:automationName': 'xcuitest',
        'appium:platformVersion': ios_version,
        'appium:deviceName': device_or_simulator_name,
        'appium:app': path_to_ios_app
      },
      endpoint: 'http://127.0.0.1:4723/wd/hub'
    }
    AppiumConnect.initialize_appium(options)
```
> ℹ️ If an optional user defined `driver_name:` is not specified in the `options` hash, the default driver name will be set to
`appium_<device_os>_<device_type>` - e.g. `:appium_ios_phone` or `:appium_ios_tablet`.
>
> ℹ️ If an `endpoint:` is not specified in the `options` hash, then the default remote endpoint URL of `http://127.0.0.1:4723/wd/hub`
will be used.
>
> ℹ️ If `global_driver:` is not specified in the `options` hash, then the driver will be initialized without global scope.

Below is an example of an `options` hash for specifying a connection to a locally hosted mobile app running on an iPad Pro
simulator. The `options` hash includes options for specifying the driver name, global driver scope, and setting the simulated
device orientation to portrait mode.
```ruby
      options = {
        driver: :appium,
        device_type: :tablet,
        driver_name: :my_custom_ipad_driver,
        global_driver: true,
        capabilities: {
          platformName: :ios,
          'appium:platformVersion': '15.4',
          'appium:deviceName': 'iPad Pro (12.9-inch) (5th generation)',
          'appium:automationName': 'XCUITest',
          'appium:orientation': 'PORTRAIT',
          'appium:app': Environ.current.ios_app_path
        }
      }
      AppiumConnect.initialize_appium(options)
```

#### Connecting to Locally Hosted Android Simulators or Physical Devices

You can run your automated tests on locally hosted Android simulators or physically connected devices using Appium and Android
Studio on macOS. You must install Android Studio, the desired Android version-specific virtual device emulators, and
Appium. Refer to [this page](https://appium.io/docs/en/2.2/quickstart/uiauto2-driver/) for information on configuring Appium to work with the Android SDK. Refer to [this page](https://github.com/appium/appium-uiautomator2-driver)
for information regarding specifying  Appium capabilities that are specific to the UiAutomator2 driver.

##### Local Android Simulators or Physical Devices using Environment Variables

If the `options` hash is not provided when calling the `TestCentricity::AppiumConnect.initialize_appium` method, the following
**Environment Variables** must be set as described in the table below.

| **Environment Variable**  | **Description**                                                                                                                |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| `DRIVER`                  | Must be set to `appium`                                                                                                        |
| `APP_PLATFORM_NAME`       | Must be set to `Android`                                                                                                       |
| `AUTOMATION_ENGINE`       | Must be set to `UiAutomator2`                                                                                                  |
| `APP_VERSION`             | Must be set to `12.0`, or which ever Android OS version you wish to run with the Android Virtual Device                        |
| `APP_DEVICE`              | Set to Android Virtual Device ID (`Pixel_2_XL_API_26`, `Nexus_6_API_23`, etc.) found in Advanced Settings of AVD Configuration |
| `DEVICE_TYPE`             | Must be set to `phone` or `tablet`                                                                                             |
| `APP`                     | Must be set to path where Android `.apk` file can be accessed and loaded                                                       || `UDID`                    | UDID of physically connected Android device (not used for simulators)                                                          |
| `ORIENTATION`             | [Optional] Set to `portrait` or `landscape`                                                                                    |
| `APP_NO_RESET`            | [Optional] Don't reset app state after each test. Set to `true` or `false`                                                     |
| `APP_FULL_RESET`          | [Optional] Perform a complete reset. Set to `true` or `false`                                                                  |
| `LOCALE`                  | [Optional] Locale to set for the simulator.  e.g.  `fr_CA`                                                                     |
| `LANGUAGE`                | [Optional] Language to set for the simulator.  e.g.  `fr`                                                                      |
| `NEW_COMMAND_TIMEOUT`     | [Optional] Time (in Seconds) that Appium will wait for a new command from the client                                           |
| `CHROMEDRIVER_EXECUTABLE` | [Optional] Absolute local path to ChromeDriver executable                                                                      |

Refer to [**section 8.4 (Using Configuration Specific Profiles in `cucumber.yml`)**](#using-configuration-specific-profiles-in-cucumber-yml) below.


##### Local Android Simulators or Physical Devices using the `options` Hash

When using the `options` hash, the following options and capabilities must be specified:
  - `driver:` must be set to `:appium`
  - `device_type:` must be set to `:tablet` or `:phone`
  - `platformName:` must be set to `Android` in the `capabilities:` hash
  - `'appium:automationName':` must be set to `UiAutomator2` in the `capabilities:` hash
  - `'appium:platformVersion':` must be set to the version of Android on the simulator or physical device
  - `'appium:deviceName':` must be set to the Android Virtual Device ID
  - `'appium:app'`: must be set to path where Android `.apk` file can be accessed and loaded

```ruby
    options = {
      driver: :appium,
      device_type: phone_or_tablet,
      capabilities: {
        platformName: :android,
        'appium:automationName': 'UiAutomator2',
        'appium:platformVersion': android_version,
        'appium:deviceName': simulator_name,
        'appium:avd': simulator_name,
        'appium:app': path_to_android_app
      },
      endpoint: 'http://localhost:4723/wd/hub'
    }
    AppiumConnect.initialize_appium(options)
```
> ℹ️ If an optional user defined `driver_name:` is not specified in the `options` hash, the default driver name will be set to
`appium_<device_os>_<device_type>` - e.g. `:appium_android_phone` or `:appium_android_tablet`.
>
> ℹ️ If an `endpoint:` is not specified in the `options` hash, then the default remote endpoint URL of ``http://127.0.0.1:4723/wd/hub``
will be used.
> 
> ℹ️ If `global_driver:` is not specified in the `options` hash, then the driver will be initialized without global scope.


Below is an example of an `options` hash for specifying a connection to a locally hosted mobile app running on an Android
tablet simulator. The `options` hash includes options for specifying the driver name and setting the simulated device orientation
to landscape mode.
```ruby
      options = {
        driver: :appium,
        device_type: :tablet,
        driver_name: :admin_tablet,
        capabilities: {
          platformName: 'Android',
          'appium:platformVersion': '12.0',
          'appium:deviceName': 'Pixel_C_API_31',
          'appium:avd': 'Pixel_C_API_31',
          'appium:automationName': 'UiAutomator2',
          'appium:orientation': 'LANDSCAPE',
          'appium:app': Environ.current.android_apk_path
        }
      }
      AppiumConnect.initialize_appium(options)
```
#### Starting and Stopping Appium Server

##### Using Appium Server with Cucumber

The Appium server must be running prior to invoking Cucumber to run your features/scenarios on locally hosted mobile simulators
or physical devices. To programmatically control the starting and stopping of Appium server with the execution of your automated
tests, place the code shown below in your `hooks.rb` file.
```ruby
    BeforeAll do
      # start Appium Server if APPIUM_SERVER = 'run'
      if ENV['APPIUM_SERVER'] == 'run'
        $server = TestCentricity::AppiumServer.new
        $server.start
      end
    end

    AfterAll do
      # close Appium driver
      TestCentricity::AppiumConnect.quit_driver
      # terminate Appium Server if command line option was specified and Appium server is running
      if ENV['APPIUM_SERVER'] == 'run' && Environ.driver == :appium && $server.running?
        $server.stop
      end
    end
```
The `APPIUM_SERVER` environment variable must be set to `run` in order to programmatically start and stop the Appium server.
This can be set by adding the following to your `cucumber.yml` file and including `-p run_appium` in your command line when
starting your Cucumber test suite(s):

    run_appium: APPIUM_SERVER=run

Refer to [**section 8.4 (Using Configuration Specific Profiles in `cucumber.yml`)**](#using-configuration-specific-profiles-in-cucumber-yml) below.


##### Using Appium Server with RSpec

The Appium server must be running prior to executing test specs on locally hosted mobile simulators or physical device. To
control the starting and stopping of the Appium server with the execution of your specs, place the code shown below in the
body of an example group:
```ruby
    before(:context) do
      # start Appium server before all of the examples in this group
      $server = TestCentricity::AppiumServer.new
      $server.start
    end

    after(:context) do
      # terminate Appium Server after all of the examples in this group
      $server.stop if Environ.driver == :appium && $server.running?
    end
```

###  Connecting to Remote Cloud Hosted iOS and Android Simulators or Physical Devices

You can run your automated tests against remote cloud hosted iOS and Android simulators and real devices using the BrowserStack,
SauceLabs, or TestingBot services.

#### Remote iOS and Android Mobile Devices on the BrowserStack service

For remotely hosted iOS and Android real devices on the BrowserStack service, refer to the [Browserstack-specific capabilities chart page](https://www.browserstack.com/app-automate/capabilities?tag=w3c)
for information regarding the options and capabilities available for the various supported mobile operating systems and
devices. BrowserStack uses only real physical devices - simulators are not available on this service.


##### Uploading your mobile app(s) to BrowserStack

Refer to the following pages for information on uploading your iOS `.ipa` or Android `.apk` app files to the BrowserStack
servers:
 - [Upload apps from filesystem](https://www.browserstack.com/docs/app-automate/appium/upload-app-from-filesystem)
 - [Upload apps using public URL](https://www.browserstack.com/docs/app-automate/appium/upload-app-using-public-url)
 - [Define custom ID for app](https://www.browserstack.com/docs/app-automate/appium/upload-app-define-custom-id)

The preferred method of uploading an app to BrowserStack is to define a custom test ID for your apps to avoid having to
modify your test configuration data with a new `app_url` after every app upload. Use the same custom test ID every time
you upload a new build of the app.

If the `UPLOAD_APP` Environment Variable is set to `true` prior to calling the `initialize_appium` method, your iOS `.ipa`
or Android `.apk` file will automatically be uploaded to the BrowserStack servers prior to running your tests. If you have
not specified a custom test ID for your apps, your tests will most likely fail as a new `app_url` will be generated, and
you will have to update your test configuration data to use the new `app_url`. If you have specified a custom test ID for
your apps, your tests should be able to run immediately after the app file upload has completed.


##### BrowserStack Mobile Devices using Environment Variables

If the `options` hash is not provided when calling the `TestCentricity::AppiumConnect.initialize_appium` method, the following
**Environment Variables** must be set as described in the table below.

| **Environment Variable** | **Description**                                                                                                                     |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `DRIVER`                 | Must be set to `browserstack`                                                                                                       |
| `BS_USERNAME`            | Must be set to your BrowserStack account user name                                                                                  |
| `BS_AUTHKEY`             | Must be set to your BrowserStack account access key                                                                                 |
| `BS_OS`                  | Must be set to `ios` or `android`                                                                                                   |
| `BS_DEVICE`              | Refer to `deviceName` capability in chart                                                                                           |
| `BS_OS_VERSION`          | Set to the OS version specified in the `platformVersion` capability in the chart                                                    |
| `DEVICE_TYPE`            | Must be set to `phone` or `tablet`                                                                                                  |
| `AUTOMATION_ENGINE`      | Must be set to `XCUITest` for iOS or `UiAutomator2` for Android                                                                     |
| `APP`                    | Must be set to URL or custom test ID of uploaded iOS `.ipa` or Android `.apk` file                                                  |
| `ORIENTATION`            | [Optional] Set to `portrait` or `landscape`                                                                                         |
| `RECORD_VIDEO`           | [Optional] Enable screen video recording during test execution (`true` or `false`)                                                  |
| `TIME_ZONE`              | [Optional] Specify custom time zone. Refer to `browserstack.timezone` capability in chart                                           |
| `IP_GEOLOCATION`         | [Optional] Specify IP Geolocation. Refer to [IP Geolocation](https://www.browserstack.com/ip-geolocation) to select a country code. |
| `SCREENSHOTS`            | [Optional] Generate screenshots for debugging (`true` or `false`)                                                                   |
| `NETWORK_LOGS`           | [Optional] Capture network logs (`true` or `false`)                                                                                 |
| `APPIUM_LOGS`            | [Optional] Generate Appium logs (`true` or `false`)                                                                                 |
| `UPLOAD_APP`             | [Optional] Automatically upload the app to BrowserStack servers if true (`true` or `false`)                                         |

Refer to [**section 8.4 (Using Configuration Specific Profiles in `cucumber.yml`)**](#using-configuration-specific-profiles-in-cucumber-yml) below.


##### BrowserStack Mobile Devices using the `options` Hash

When using the `options` hash, the following options and capabilities must be specified:
  - `driver:` must be set to `:browserstack`
  - `device_type:` must be set to `:tablet` or `:phone`
  - `platformName:` must be set to `ios` or `android` in the `capabilities:` hash
  - `'appium:automationName':` must be set to to `XCUITest` for iOS or `UiAutomator2` for Android in the `capabilities:` hash
  - `'appium:platformVersion':` must be set to the version of iOS on the simulator or physical device
  - `'appium:deviceName':` must be set to the name of the iOS simulator or physical device
  - `'appium:app'`: must be set to URL or custom test ID of uploaded iOS `.ipa` or Android `.apk` file

```ruby
    options = {
      driver: :browserstack,
      device_type: phone_or_tablet,
      capabilities: {
        platformName: platform,
        'appium:automationName': automation_name,
        'appium:platformVersion': os_version,
        'appium:deviceName': device_name,
        'appium:app': app_url_or_custom_ID,
        'bstack:options': {
          userName: bs_account_user_name,
          accessKey: bs_account_access_key
        }
      }
    }
    AppiumConnect.initialize_appium(options)
```
> ℹ️ If an optional user defined `driver_name:` is not specified in the `options` hash, the default driver name will be set to
`:browserstack_<device_os>_<device_type>` - e.g. `:browserstack_ios_phone` or `:browserstack_android_tablet`.
>
> ℹ️ If an `endpoint:` is not specified in the `options` hash, then the default remote endpoint URL will be set to the following:
>
> `https://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub-cloud.browserstack.com/wd/hub`
>
> ℹ️ If `global_driver:` is not specified in the `options` hash, then the driver will be initialized without global scope.

This default endpoint requires that the `BS_USERNAME` Environment Variable is set to your BrowserStack account user name and
the `BS_AUTHKEY` Environment Variable is set to your BrowserStack access key.

Below is an example of an `options` hash for specifying a connection to a mobile app running on an iOS tablet hosted on
BrowserStack. The `options` hash includes options for specifying the driver name, and capabilities for setting geoLocation,
time zone, Appium version, device orientation, language, locale, and various test configuration options.
```ruby
    options = {
      driver: :browserstack,
      device_type: :tablet,
      driver_name: :admin_tablet,
      endpoint: "https://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub-cloud.browserstack.com/wd/hub",
      capabilities: {
        platformName: 'ios',
        'appium:platformVersion': '17',
        'appium:deviceName': 'iPad Pro 12.9 2021',
        'appium:automationName': 'XCUITest',
        'appium:app': 'RNDemoAppiOS',
        'bstack:options': {
          userName: ENV['BS_USERNAME'],
          accessKey: ENV['BS_AUTHKEY'],
          projectName: 'ALP AP',
          buildName: "Test Build #{ENV['BUILD_NUM']}",
          sessionName: 'AU Regression Suite',
          appiumVersion: '2.0.1',
          geoLocation: 'AU',
          timezone: 'Perth',
          deviceOrientation: 'landscape'
        },
        language: 'En',
        locale: 'en_AU'
      }
    }
    AppiumConnect.initialize_appium(options)
```


#### Remote iOS and Android Physical Devices and Simulators on the TestingBot service

For remotely hosted iOS and Android simulators and real devices on the TestingBot service, the following **Environment
Variables** must be set as described in the table below. Refer to the [TestingBot List of Devices page](https://testingbot.com/support/devices) for information
regarding the specific capabilities.


##### Uploading your mobile app(s) to TestingBot

Refer to the following pages for information on uploading your iOS `.ipa` or `.app` or Android `.apk` app files to the
TestingBot servers:
- [Upload your App](https://testingbot.com/support/mobile/upload.html)
- [TestingBot Storage - Upload File API doc](https://testingbot.com/support/api#upload)

The preferred method of uploading an app to TestingBot is to define a custom test ID for your apps to avoid having to
modify your test configuration data with a new `app_url` after every app upload. Use the same custom test ID every time
you upload a new build of the app.

If the `UPLOAD_APP` Environment Variable is set to `true` prior to calling the `initialize_appium` method, your iOS `.ipa`
or `.app`, or Android `.apk` file will automatically be uploaded to the TestingBot servers prior to running your tests. If
you have not specified a custom test ID for your apps, your tests will most likely fail as a new `app_url` will be generated,
and you will have to update your test configuration data to use the new `app_url`. If you have specified a custom test ID
for your apps, your tests should be able to run immediately after the app file upload has completed.

When specifying you app's custom test ID in either the `APP` Environment Variable or as part of the `options` hash, the
custom test ID is specified as `tb://your_custom_id`.


##### TestingBot Mobile Devices using Environment Variables

If the `options` hash is not provided when calling the `TestCentricity::AppiumConnect.initialize_appium` method, the following
**Environment Variables** must be set as described in the table below.

| **Environment Variable** | **Description**                                                                                                                                     |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| `DRIVER`                 | Must be set to `testingbot`                                                                                                                         |
| `TB_USERNAME`            | Must be set to your TestingBot account user name                                                                                                    |
| `TB_AUTHKEY`             | Must be set to your TestingBot account access key                                                                                                   |
| `TB_OS`                  | Must be set to `ios` or `android`                                                                                                                   |
| `TB_DEVICE`              | Refer to `deviceName` capability in chart                                                                                                           |
| `TB_OS_VERSION`          | Refer to `version` capability in chart                                                                                                              |
| `DEVICE_TYPE`            | Must be set to `phone` or `tablet`                                                                                                                  |
| `AUTOMATION_ENGINE`      | Must be set to `XCUITest` for iOS or `UiAutomator2` for Android                                                                                     |
| `REAL_DEVICE`            | Must be set to `true` for real devices                                                                                                              |
| `APP`                    | Must be set to URL or custom test ID of uploaded iOS `.ipa` or `.app`, or Android `.apk` file                                                       |
| `TIME_ZONE`              | [Optional] Specify custom time zone. Refer to [list of time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)                    |
| `IP_GEOLOCATION`         | [Optional] Specify IP Geolocation. Refer to [Geolocation Testing](https://testingbot.com/support/mobile/options.html#geo) to select a country code. |
| `RECORD_VIDEO`           | [Optional] Enable screen video recording during test execution (`true` or `false`)                                                                  |
| `SCREENSHOTS`            | [Optional] Generate screenshots for debugging (`true` or `false`)                                                                                   |
| `UPLOAD_APP`             | [Optional] Automatically upload the app to TestingBot servers if true (`true` or `false`)                                                           |

Refer to [**section 8.4 (Using Configuration Specific Profiles in `cucumber.yml`)**](#using-configuration-specific-profiles-in-cucumber-yml) below.


##### TestingBot Mobile Devices using the `options` Hash

When using the `options` hash, the following options and capabilities must be specified:
- `driver:` must be set to `:testingbot`
- `device_type:` must be set to `:tablet` or `:phone`
- `platformName:` must be set to `ios` or `android` in the `capabilities:` hash
- `'appium:automationName':` must be set to to `XCUITest` for iOS or `UiAutomator2` for Android in the `capabilities:` hash
- `'appium:platformVersion':` must be set to the version of iOS on the simulator or physical device
- `'appium:deviceName':` must be set to the name of the iOS simulator or physical device
- `'appium:realDevice':` must be set to `true` if testing on real physical device
- `'appium:app'`: must be set to URL or custom test ID of uploaded iOS `.ipa` or `.app`, or Android `.apk` file

```ruby
    options = {
      driver: :testingbot,
      device_type: phone_or_tablet,
      capabilities: {
        platformName: platform,
        'appium:automationName': automation_name,
        'appium:platformVersion': os_version,
        'appium:deviceName': device_name,
        'appium:realDevice': true_or_false,
        'appium:app': app_url_or_custom_ID,
        'tb:options': {
          # other platform specific options
        }
      }
    }
    AppiumConnect.initialize_appium(options)
```
> ℹ️ If an optional user defined `driver_name:` is not specified in the `options` hash, the default driver name will be set to
`:testingbot_<device_os>_<device_type>` - e.g. `:testingbot_ios_phone` or `:testingbot_android_tablet`.
>
> ℹ️ If an `endpoint:` is not specified in the `options` hash, then the default remote endpoint URL will be set to the following:
>
> `http://#{ENV['TB_USERNAME']}:#{ENV['TB_AUTHKEY']}@hub.testingbot.com/wd/hub`
>
> ℹ️ If `global_driver:` is not specified in the `options` hash, then the driver will be initialized without global scope.

This default endpoint requires that the `TB_USERNAME` Environment Variable is set to your TestingBot account user name and
the `TB_AUTHKEY` Environment Variable is set to your TestingBot access key.

Below is an example of an `options` hash for specifying a connection to a mobile app running on a real physical iPhone hosted
on TestingBot. The `options` hash includes options for specifying the driver name, and capabilities for setting geoLocation,
time zone, Appium version, and various test configuration options.
```ruby
    options = {
      driver: :testingbot,
      device_type: :phone,
      driver_name: :tb_ios_phone,
      endpoint: "http://#{ENV['TB_USERNAME']}:#{ENV['TB_AUTHKEY']}@hub.testingbot.com/wd/hub",
      capabilities: {
        platformName: 'ios',
        'appium:platformVersion': '17.0',
        'appium:deviceName': 'iPhone 14',
        'appium:realDevice': true,
        'appium:automationName': 'XCUITest',
        'appium:app': 'tb://RNDemoAppiOS',
        'tb:options': {
          name: ENV['AUTOMATE_PROJECT'],
          build: "Test Build #{ENV['BUILD_NUM']}",
          appiumVersion: '2.2.1'
        }
      }
    }
    AppiumConnect.initialize_appium(options)
```


#### Remote iOS and Android Physical Devices and Simulators on the Sauce Labs service

For remotely hosted iOS and Android simulators and real devices on the Sauce Labs service, the following **Environment Variables**
must be set as described in the table below. Refer to the [Platform Configurator page](https://saucelabs.com/platform/platform-configurator)
to obtain information regarding the specific capabilities.


##### Uploading your mobile app(s) to Sauce Labs

Refer to the following pages for information on uploading your iOS `.ipa` or `.app` or Android `.apk` app files to the
Sauce Labs servers:
- [Mobile App Storage](https://docs.saucelabs.com/mobile-apps/app-storage/)

The TestCentricity Mobile gem does not currently support automatic upload of app files to Sauce Labs servers. Uploading 
will have to be performed manually or via your CI workflow. If you have not specified a custom test ID for your apps, your
tests will most likely fail as a new `app_url` will be generated, and you will have to update your test configuration data
to use the new `app_url`. If you have specified a custom test ID for your apps, your tests should be able to run without
modifying your test configs.


##### Sauce Labs Mobile Devices using Environment Variables

If the `options` hash is not provided when calling the `TestCentricity::AppiumConnect.initialize_appium` method, the following
**Environment Variables** must be set as described in the table below.

| **Environment Variable** | **Description**                                                                                                 |
|--------------------------|-----------------------------------------------------------------------------------------------------------------|
| `DRIVER`                 | Must be set to `saucelabs`                                                                                      |
| `SL_USERNAME`            | Must be set to your Sauce Labs account user name or email address                                               |
| `SL_AUTHKEY`             | Must be set to your Sauce Labs account access key                                                               |
| `SL_DATA_CENTER`         | Must be set to your Sauce Labs account Data Center assignment (`us-west-1`, `eu-central-1`, `apac-southeast-1`) |
| `SL_OS`                  | Must be set to `ios` or `android`                                                                               |
| `SL_DEVICE`              | Refer to `deviceName` capability in chart                                                                       |
| `SL_OS_VERSION`          | Refer to `platformVersion` capability in the Config Script section of the Platform Configurator page            |
| `AUTOMATION_ENGINE`      | Must be set to `XCUITest` for iOS or `UiAutomator2` for Android                                                 |
| `DEVICE_TYPE`            | Must be set to `phone` or `tablet`                                                                              |
| `ORIENTATION`            | [Optional] Set to `portrait` or `landscape`                                                                     |
| `RECORD_VIDEO`           | [Optional] Enable screen video recording during test execution (`true` or `false`)                              |
| `SCREENSHOTS`            | [Optional] Generate screenshots for debugging (`true` or `false`)                                               |

Refer to [**section 8.4 (Using Configuration Specific Profiles in `cucumber.yml`)**](#using-configuration-specific-profiles-in-cucumber-yml) below.


##### Sauce Labs Mobile Devices using the `options` Hash

When using the `options` hash, the following options and capabilities must be specified:
- `driver:` must be set to `:saucelabs`
- `device_type:` must be set to `:tablet` or `:phone`
- `platformName:` must be set to `ios` or `android` in the `capabilities:` hash
- `'appium:automationName':` must be set to to `XCUITest` for iOS or `UiAutomator2` for Android in the `capabilities:` hash
- `'appium:platformVersion':` must be set to the version of iOS on the simulator or physical device
- `'appium:deviceName':` must be set to the name of the iOS simulator or physical device
- `'appium:app'`: must be set to URL or custom test ID of uploaded iOS `.ipa` or `.app`, or Android `.apk` file

```ruby
    options = {
      driver: :saucelabs,
      device_type: phone_or_tablet,
      capabilities: {
        platformName: platform,
        'appium:automationName': automation_name,
        'appium:platformVersion': os_version,
        'appium:deviceName': device_name,
        'appium:app': app_url_or_custom_ID,
        'sauce:options': {
          # other platform specific options
        }
      }
    }
    AppiumConnect.initialize_appium(options)
```
> ℹ️ If an optional user defined `driver_name:` is not specified in the `options` hash, the default driver name will be set to
`:saucelabs_<device_os>_<device_type>` - e.g. `:saucelabs_ios_phone` or `:saucelabs_android_tablet`.
>
> ℹ️ If an `endpoint:` is not specified in the `options` hash, then the default remote endpoint URL will be set to the following:
>
> `https://#{ENV['SL_USERNAME']}:#{ENV['SL_AUTHKEY']}@ondemand.#{ENV['SL_DATA_CENTER']}.saucelabs.com:443/wd/hub`
>
> ℹ️ If `global_driver:` is not specified in the `options` hash, then the driver will be initialized without global scope.

This default endpoint requires that the `SL_USERNAME` Environment Variable is set to your Sauce Labs account user name, the
`SL_AUTHKEY` Environment Variable is set to your Sauce Labs access key, and the `SL_DATA_CENTER` Environment Variable is
set to your Sauce Labs account Data Center assignment (`us-west-1`, `eu-central-1`, `apac-southeast-1`).


#### Remote iOS and Android Physical Devices and Simulators on Unsupported Cloud Hosting Services

Limited support is provided for executing automated tests against remotely hosted iOS and Android simulators and real devices
on other cloud hosting services that are currently not supported. You must call the `AppiumConnect.initialize_appium` method
with an `options` hash - Environment Variables cannot be used to specify a user-defined custom Appium driver instance.

Prior to calling the `AppiumConnect.initialize_appium` method, you must set the following `Environ` attributes:
  - `Environ.platform` set to `:mobile`
  - `Environ.device_os` to either `:ios` or `:android`
  - `Environ.device` to either `:simulator` or `:device`, dependent on whether the target mobile platform is a real device
    or simulator.
  - `Environ.device_name` set to device name specified by hosting service

The following options and capabilities must be specified:
  - `driver:` must be set to `:custom`
  - `device_type:` must be set to `:tablet` or `:phone`
  - `endpoint:` must be set to the endpoint URL configuration specified by the hosting service

All other required capabilities specified by the hosting service configuration documentation should be included in the
`capabilities:` hash.
```ruby
    # specify mobile platform, device type, device os, and device name
    Environ.platform = :mobile
    Environ.device = :device
    Environ.device_os = :ios
    Environ.device_name = device_name_from_chart
    # instantiate a cloud hosted mobile device or simulator on an unsupported hosting service
    options = {
      driver: :custom,
      device_type: :phone,
      endpoint: endpoint_url,
      capabilities: {
        # capabilities as specified by the hosting service
      }
    }
    AppiumConnect.initialize_appium(options)
```
> ℹ️ If an optional user defined `driver_name:` is not specified in the `options` hash, the default driver name will be set to
`:custom_<device_os>_<device_type>` - e.g. `:custom_ios_phone` or `:custom_android_tablet`.
>
> ℹ️ If `global_driver:` is not specified in the `options` hash, then the driver will be initialized without global scope.


### Using Configuration Specific Profiles in cucumber.yml

While you can set **Environment Variables** in the command line when invoking Cucumber, a preferred method of specifying
and managing target platforms is to create platform specific **Profiles** that set the appropriate **Environment Variables**
for each target platform in your `cucumber.yml` file.

Below is a list of Cucumber **Profiles** for supported locally and remotely hosted iOS and Android simulators and real
devices (put these in in your `cucumber.yml` file). Before you can use the BrowserStack, SauceLabs, or TestingBot services,
you will need to replace the *INSERT USER NAME HERE* and *INSERT PASSWORD HERE* placeholder text with your user account
and authorization code for the cloud service(s) that you intend to connect with.

> ⚠️ Cloud service credentials should not be stored as text in your `cucumber.yml` file where it can be exposed by anyone
with access to your version control system.


    #==============
    # conditionally load Screen Object implementations based on which target platform we're running on
    #==============

    ios:     PLATFORM=ios --tags @ios -r features/support/ios -e features/support/android
    android: PLATFORM=android --tags @android -r features/support/android -e features/support/ios


    #==============
    # profiles for mobile device screen orientation
    #==============

    landscape: ORIENTATION=landscape
    portrait:  ORIENTATION=portrait


    #==============
    # profile to start Appium Server prior to running locally hosted mobile app tests on iOS or Android simulators or
    # physical devices
    #==============
    run_appium: APPIUM_SERVER=run


    #==============
    # profiles for native iOS apps hosted within XCode iOS simulators
    # NOTE: Requires installation of XCode, iOS version specific target simulators, and Appium
    #==============

    appium_ios: DRIVER=appium --profile ios AUTOMATION_ENGINE=XCUITest APP_PLATFORM_NAME="iOS" NEW_COMMAND_TIMEOUT="30" <%= mobile %>
    app_ios_14: --profile appium_ios APP_VERSION="14.5"
    app_ios_15: --profile appium_ios APP_VERSION="15.4"

    iphone_12PM_14_sim: --profile app_ios_14 DEVICE_TYPE=phone APP_DEVICE="iPhone 12 Pro Max"
    iphone_13PM_15_sim: --profile app_ios_15 DEVICE_TYPE=phone APP_DEVICE="iPhone 13 Pro Max"
    iphone_11_14_sim:   --profile app_ios_14 DEVICE_TYPE=phone APP_DEVICE="iPhone 11"
    ipad_pro_12_15_sim: --profile app_ios_15 DEVICE_TYPE=tablet APP_DEVICE="iPad Pro (12.9-inch) (5th generation)"


    #==============
    # profiles for native Android apps hosted within Android Studio Android Virtual Device emulators
    # NOTE: Requires installation of Android Studio, Android version specific virtual device simulators, and Appium
    #==============

    appium_android:    DRIVER=appium --profile android AUTOMATION_ENGINE=UiAutomator2 APP_PLATFORM_NAME="Android" <%= mobile %>
    app_android_12:    --profile appium_android APP_VERSION="12.0"
    pixel_5_api31_sim: --profile app_android_12 DEVICE_TYPE=phone APP_DEVICE="Pixel_5_API_31"


    #==============
    # profiles for remotely hosted devices on the BrowserStack service
    # WARNING: Credentials should not be stored as text in your cucumber.yml file where it can be exposed by anyone with access
    #          to your version control system
    #==============

    browserstack: DRIVER=browserstack BS_USERNAME="<INSERT USER NAME HERE>" BS_AUTHKEY="<INSERT PASSWORD HERE>" TEST_CONTEXT="TestCentricity"

    # BrowserStack iOS real device native app profiles
    bs_ios:           --profile browserstack --profile ios BS_OS=ios <%= mobile %>
    bs_iphone:        --profile bs_ios DEVICE_TYPE=phone
    bs_iphone13PM_15: --profile bs_iphone BS_OS_VERSION="15" BS_DEVICE="iPhone 13 Pro Max"
    bs_iphone11_14:   --profile bs_iphone BS_OS_VERSION="14" BS_DEVICE="iPhone 11"

    # BrowserStack Android real device native app profiles
    bs_android: --profile browserstack --profile android BS_OS=android <%= mobile %>
    bs_pixel5:  --profile bs_android BS_DEVICE="Google Pixel 5" BS_OS_VERSION="12.0" DEVICE_TYPE=phone


    #==============
    # profiles for remotely hosted devices on the SauceLabs service
    # WARNING: Credentials should not be stored as text in your cucumber.yml file where it can be exposed by anyone with access
    #          to your version control system
    #==============

    saucelabs: DRIVER=saucelabs SL_USERNAME="<INSERT USER NAME HERE>" SL_AUTHKEY="<INSERT PASSWORD HERE>" DATA_CENTER="us-west-1" AUTOMATE_PROJECT="TestCentricity - SauceLabs"

    # SauceLabs iOS real device native app profiles
    sl_ios:           --profile saucelabs --profile ios SL_OS=ios <%= mobile %>
    sl_iphone:        --profile sl_ios DEVICE_TYPE=phone
    sl_iphone13PM_15: --profile sl_iphone SL_DEVICE="iPhone 13 Pro Max Simulator" SL_OS_VERSION="15.4"

    # SauceLabs Android real device native app profiles
    sl_android: --profile saucelabs --profile android SL_OS=android <%= mobile %>
    sl_pixel5:  --profile sl_android SL_DEVICE="Google Pixel 5 GoogleAPI Emulator" SL_OS_VERSION="12.0" DEVICE_TYPE=phone


    #==============
    # profiles for remotely hosted devices on the TestingBot service
    # WARNING: Credentials should not be stored as text in your cucumber.yml file where it can be exposed by anyone with access
    #          to your version control system
    #==============

    testingbot: DRIVER=testingbot TB_USERNAME="<INSERT USER NAME HERE>" TB_AUTHKEY="<INSERT PASSWORD HERE>" AUTOMATE_PROJECT="TestCentricity - TestingBot"

    # TestingBot iOS real device native app profiles
    tb_ios:               --profile testingbot --profile ios TB_OS=iOS <%= mobile %>
    tb_iphone:            --profile tb_ios DEVICE_TYPE=phone
    tb_iphone11_14_dev:   --profile tb_iphone TB_OS_VERSION="14.0" TB_DEVICE="iPhone 11" REAL_DEVICE=true
    tb_iphone11_14_sim:   --profile tb_iphone TB_OS_VERSION="14.2" TB_DEVICE="iPhone 11"
    tb_iphone13PM_15_sim: --profile tb_iphone TB_OS_VERSION="15.4" TB_DEVICE="iPhone 13 Pro Max"

    # TestingBot Android real device native app profiles
    tb_android:    --profile testingbot --profile android TB_OS=Android <%= mobile %>
    tb_pixel_dev:  --profile tb_android TB_DEVICE="Pixel" TB_OS_VERSION="9.0" DEVICE_TYPE=phone REAL_DEVICE=true
    tb_pixel6_sim: --profile tb_android TB_DEVICE="Pixel 6" TB_OS_VERSION="12.0" DEVICE_TYPE=phone


To specify a mobile simulator or real device target using a profile at runtime, you use the flag `--profile` or `-p` followed
by the profile name when invoking Cucumber in the command line. For instance, the following command specifies that Cucumber will
run tests against an iPad Pro (12.9-inch) (5th generation) with iOS version 15.4 in an XCode Simulator in portrait orientation:

    cucumber -p ipad_pro_12_15_sim -p portrait
    
    NOTE:  Appium must be running prior to executing this command

You can ensure that Appium Server is running by including `-p run_appium` in your command line:

    cucumber -p ipad_pro_12_15_sim -p portrait -p run_appium


The following command specifies that Cucumber will run tests against a cloud hosted iPhone 13 Pro Max running iOS 15.4 on the
BrowserStack service:

    cucumber -p bs_iphone13PM_15


---
## Recommended Project Organization and Structure

Below is an example of the project structure of a typical Cucumber based native mobile app test automation framework with a Screen
Object Model architecture. `ScreenObject` class definitions should be stored in the `/features/support/<platform>/screens`
folders, organized in functional area sub-folders as needed. Likewise, `ScreenSection` class definitions should be stored in
the `/features/support/<platform>/sections` folder, where `<platform>` is typically `ios` or `android`.

    my_automation_project
        ├── config
        │   ├── locales
        │   ├── test_data
        │   └── cucumber.yml
        ├── features
        │   ├── step_definitions
        │   ├── support
        │   │   ├── android
        |   |   |   ├── screens
        |   |   |   └── sections
        │   │   ├── ios
        |   |   |   ├── screens
        |   |   |   └── sections
        │   │   ├── shared_components
        |   |   |   ├── screens
        |   |   |   └── sections
        │   │   ├── env.rb
        │   │   ├── hooks.rb
        │   │   └── world_screens.rb
        ├── Gemfile
        └── README.md


---
## Mobile Test Automation Framework Implementation

![TestCentricity Mobile Framework Overview](https://raw.githubusercontent.com/TestCentricity/testcentricity_mobile/main/.github/images/TC_Mobile.jpg "TestCentricity Mobile Framework Overview")


---
## Copyright and License

TestCentricity™ Framework is Copyright (c) 2014-2024, Tony Mrozinski.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
