
Feature: Pick ups

  @personas
  Scenario: Quantity and return button
    Given I am Normin
    Then I see the number of "Returns" on each page

  @personas
  Scenario: No pickup button when there are no returns
    Given I am Peter
    And I am in the borrow section
    Then I don't see the "Pick ups" button

  @personas
  Scenario: Pick up overview
    Given I am Normin
    When I press the "Pick ups" link
    Then I see my "Pick ups"
    And the "Pick ups" are sorted by date and inventory pool
    And each of the "Pick ups" shows items to pick up
    And the items are sorted alphabetically and grouped by model name and number of items
