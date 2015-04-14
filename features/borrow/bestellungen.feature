
Feature: Orders

  Background:
    Given I am Normin

  @personas
  Scenario: Order counters
    Then I see the number of submitted, unapproved orders on every page

  @personas
  Scenario: Overview page for my orders
    When I am listing my orders
    Then I see my submitted, unapproved orders
    And I see the information that the order has not yet been approved
    And the orders are sorted by date and inventory pool
    And each order shows the items to approve
    And the items in the order are sorted alphabetically and by model name
