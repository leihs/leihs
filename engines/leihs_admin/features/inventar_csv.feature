Feature: Inventory (CSV export)

  @personas
  Scenario: Export of the entire inventory to a CSV file
    Given I am Gino
    And I open the list of inventory pools
    Then I can export to a CSV file
