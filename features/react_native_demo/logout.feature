@mobile @ios @android @regression @rn_demo


Feature:  Log Out
  In order to ensure the security of critical business and customer data
  As a developer of the TestCentricity Mobile gem
  I expect users to be able to log out of the app


  Background:
    Given I have launched the SauceLabs My Demo app
    And I am on the Products screen
    And I choose to log out


  Scenario:  Verify users can cancel logging out of app
    When I dismiss the popup request modal
    And I close the navigation menu
    Then I expect the Products screen to be correctly displayed


  Scenario:  Verify users can log out of app
    When I accept the popup request modal
    Then I expect the Login screen to be correctly displayed
