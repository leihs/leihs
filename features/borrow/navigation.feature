
Feature: Navigation

  Um mich durch die Applikation navigieren zu können
  möchte ich als Ausleiher
  Navigationsmöglichkeiten haben

  @personas @javascript
  Scenario: Navigation for borrowers
    Given I am Normin
    And I am listing the main categories
    Then I can see the navigation bars
    And the navigation contains "To pick up"
    And the navigation contains "To return"
    And the navigation contains "Orders"
    And the navigation contains "Inventory pools"
    And the navigation contains "User"
    And the navigation contains "Log out"

  @personas @javascript
  Scenario: Navigation for managers
    Given I am Pius
    And I am listing the main categories
    Then I can see the navigation bars
    And the navigation contains "To pick up"
    And the navigation contains "To return"
    And the navigation contains "Orders"
    And the navigation contains "Inventory pools"
    And the navigation contains "Manage"
    And the navigation contains "User"
    And the navigation contains "Log out"

  @personas @javascript
  Scenario: Navigation for validators
    Given I am Andi
    And I am listing the main categories
    Then I can see the navigation bars
    And the navigation contains "To pick up"
    And the navigation contains "To return"
    And the navigation contains "Orders"
    And the navigation contains "Inventory pools"
    And the navigation contains "Manage"
    And the navigation contains "User"
    And the navigation contains "Log out"

  @personas
  Scenario: Home button
    Given I am Normin
    Then I see a home button in the navigation bars
    When I use the home button
    Then I am listing the main categories
