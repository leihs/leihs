
Feature: Inventory pools

  @personas
  Scenario: Inventory pool information
    Given I am Normin
    When I click on the inventory pool link
    Then I see the inventory pools I have access to
    And I see only inventory pools containing borrowable items
    And I see a description for each inventory pool
    And the inventory pools are sorted alphabetically on this page
