
Feature: Purpose

  Background:
    Given I am Pius

  @personas
  Scenario: Independence
    When a purpose is saved, it is independent of its orders
     And each entry of a submitted order refers to a purpose
     And each entry of an order can refer to a purpose

  @javascript @personas @browser
  Scenario: Places where I see the purpose
    When I edit an order
    Then I see the purpose
    When I open a hand over
    Then I see the assigned purpose on each line

  @javascript @personas @problematic
  Scenario: Places where I can edit the purpose
    When I edit an order
    Then I can edit the purpose

  @javascript @browser @personas @problematic
  Scenario: Handing over items will copy the existing purposes to any blank purposes
    When I open a hand over
     And I click an inventory code input field of an item line
     And I select one of those
     And I add an item to the hand over by providing an inventory code
     And I add an option to the hand over by providing an inventory code and a date range
    And I define a purpose
    Then only items without purpose are assigned that purpose

  @javascript @browser @personas @problematic
  Scenario: Handing over items that all have a purpose
    When I open a hand over
    And all selected items have an assigned purpose
    Then I cannot assign any more purposes

  @javascript @browser @personas
  Scenario: Handing over without purpose with required purpose
    Given the current inventory pool requires purpose
    When I open a hand over
    And none of the selected items have an assigned purpose
    Then I am told during hand over to assign a purpose
    And only when I assign a purpose
    Then I can finish the hand over

  @javascript @browser @personas
  Scenario: Handing over without purpose without required purpose
    Given the current inventory pool doesn't require purpose
    When I open a hand over
    And none of the selected items have an assigned purpose
    Then I am told during hand over to assign a purpose
    But I do not assign a purpose
    Then I can finish the hand over

  @javascript @browser @personas
  Scenario: Hand overs with a few items that don't have a purpose are possible
    When I open a hand over
    And I click an inventory code input field of an item line
    And I select one of those
    And I add an item to the hand over by providing an inventory code
    And I add an option to the hand over by providing an inventory code and a date range
    Then I don't have to assign a purpose in order to finish the hand over
