@mobile @ios @android @regression @rn_demo


Feature:  Verify WebView
  In order to ensure that WebViews are supported
  As a developer of the TestCentricity Mobile gem
  I expect to be able to validate that web content is loaded into a WebView


  Scenario:  Verify WebView
    Given I have launched the SauceLabs My Demo app
    And I am on the Webview screen
    When I enter the url for the Apple web site
    Then I expect the Web Page Viewer screen to be correctly displayed
