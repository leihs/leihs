
Feature: Value list

  Background:
    Given I am Pius

  @javascript @browser @personas
  Scenario: What I want to see on the value list
    Given I open a value list
    Then I want to see the following sections in the value list:
    | Section  |
    | Date     |
    | Title    |
    | Borrower |
    | Lender   |
    | List     |

  @javascript @browser @personas
  Scenario: Content of a value list
    Given I open a value list
    Then the list contains the following columns:
    | Column             |
    | Consecutive number |
    | Inventory code     |
    | Model name         |
    | End date           |
    | Quantity           |
    | Price              |
    And the models in the value list are sorted alphabetically

  @javascript @personas
  Scenario: Printing value lists from the list of orders
    Given there is an order with at least two models and at least two items per model were ordered
    When I open an order
    And I select multiple reservations of the order
    And I open the value list
    Then I see the value list for the selected reservations
    And the unassigned reservations are summarized
    And the price shown for the unassigned reservations is equal to the highest price of any of the items of that model within this inventory pool

  @javascript @personas
  Scenario: Printing a value list from the handover view
    Given there is an order with at least two models and at least two items per model were ordered
    And each model has exactly one assigned item
    When I open the hand over
    And I select multiple reservations of the hand over
    And I open the value list
    Then I see the value list for the selected reservations
    And the price shown for the unassigned reservations is equal to the highest price of any of the items of that model within this inventory pool
    And the price shown for the assigned reservations is that of the assigned item
    And the unassigned reservations are summarized
    And any options are priced according to their price set in the inventory pool

  @javascript @browser @personas
  Scenario: Totals
    Given I open a value list
    Then one line shows the grand total
    And that shows the totals of the columns:
     | Column   |
     | Quantity |
     | Value    |
