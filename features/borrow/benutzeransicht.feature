
Feature: Viewing my user data

  Background:
    Given I am Normin

  @personas @javascript
  Scenario: Viewing my own user data
    When I hover over my name
    And I click "User data"
    Then I get to the "User Data" page
    And I can see my user data
    And the user data consist of
    |First name|
    |Last name|
    |Email|
    |Phone number|
