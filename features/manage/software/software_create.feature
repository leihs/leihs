Feature: create a software license

  In order to create a software license
  As an Inventory Manager
  I want to have functionalities to create a software license

  Background:
    Given I am Mike

  @personas @javascript
  Scenario: create Software license with maintenance value with 2 decimal
    Given a software product exists
    When I create a new software license
    And I fill in all the required fields for the license
    And I change the value for maintenance contract
    And the possible currencies are
      | CHF |
      | EUR |
      | USD |
    And I select "CHF" from the field currency
    And I type the amount "1200" into the field "maintenance amount"
    And I save
    Then the "maintenance currency" is saved as "CHF"
    Then the "maintenance amount" is saved as "1,200.00"
