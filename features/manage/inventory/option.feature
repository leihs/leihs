
Feature: Option

  Background:
    Given I am Mike

  @javascript @browser @personas
  Scenario: Adding options
    Given I open the inventory
    When I add a new Option
    And I edit the following details
    | Field          | Value        |
    | Product        | Test Option  |
    | Price          | 50           |
    | Inventory code | Test Barcode |
    And I save
    Then the information is saved

  @javascript @browser @personas
  Scenario: Editing an option
    Given I open the inventory
    When I edit an existing Option
    And I edit the following details
    | Field          | Value          |
    | Product        | Test Option x  |
    | Price          | 51             |
    | Inventory code | Test Barcode x |
    And I save
    Then the information is saved
