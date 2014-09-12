Feature: Close Contract

  In order to take back things
  As a lending manager
  I want to be able to take back items and close a contract

  Background:
    Given I am Pius

  @javascript @browser @personas
  Scenario: Take back all items of a contract
     When I open a take back
      And I select all lines of an open contract
      And I click take back
     Then I see a summary of the things I selected for take back
     When I click take back inside the dialog
     Then the contract is closed and all items are returned
