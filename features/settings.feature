Feature: Defining application settings through web interface

  Scenario: The settings are existing
    Given I am "Normin"
    When I go to the home page
    Then I am on the home page

  Scenario: The settings are missing
    Given I am "Normin"
    When the settings are not exising
    Then there is an error for the missing settings
    Given I am "Ramon"
    When I go to the home page
    Then I am on the settings page

  Scenario: Editing the settings
    Given I am "Ramon"
    When I go to the settings page
    Then I am on the settings page
    And I can edit the settings
    And the settings are persisted
