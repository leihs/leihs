
Feature: Returning stuff

  @personas
  Scenario: Quantities and return button
    Given I am Normin
    Then I see the number of "Returns" on each page

  @personas
  Scenario: No return button if you don't have anything to return
    Given I am Ramon
    And I am in the borrow section
    Then I don't see the "Returns" button

  @personas
  Scenario: Return overview
    Given I am Normin
    When I press the "Returns" link
    Then I see my "Returns"
    And the "Returns" are sorted by date and inventory pool
    And each of the "Returns" shows items to return
    And the items are sorted alphabetically by model name
