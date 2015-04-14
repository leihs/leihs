
Feature: Viewing my user data

  Background:
    Given I am Normin

  @personas
  Scenario: Viewing my own user data
    When I click on my name
    Then I get to the "User Data" page
    And I can see my user data
    And the user data consist of
    |First name|
    |Last name|
    |Email|
    |Phone number|

  @javascript @personas
  Scenario: Seeing user data underneath the user name
    When I hover over my name
    And I view my user data
    Then I get to the "User Data" page
