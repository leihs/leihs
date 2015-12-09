
Feature: Rüstliste

  Um die Gegenstände in den Gestellen möglichst schnell zu finden
  möchte ich als Verleiher
  dass mir das System eine Rüstliste mit Auflistung der jeweiligen Gestellen gibt

  Background:
    Given I am Pius

  @personas
  Scenario: What I want to see on the picking list
    When I open a picking list
    Then I want to see the following sections in the picking list:
    | Section  |
    | Date     |
    | Title    |
    | Borrower |
    | Lender   |
    | List     |

  @personas @javascript @browser
  Scenario: Content of a picking list before hand over -- unassigned inventory codes
    Given there is a hand over with at least one unproblematic model and an option
    And I open the hand over
    And I assign an inventory code to the unproblematic model
    And the item is assigned to the line
    And a line has no item assigned yet and this line is marked
    And an option line is marked
    When I open the picking list
    Then the lists are sorted by hand over date
    And each list contains the following columns
      | Column                            |
      | Quantity                          |
      | Inventory code                    |
      | Model name                        |
      | available quantity x Room / Shelf |
    And each list will sorted after models, then sorted after room and shelf of the most available locations
    And in the list, the assigned items will displayed with inventory code, room and shelf
    And in the list, the not assigned items will displayed without inventory code
    And items without assigned room or shelf are shown with their available quantity for the customer and "x Location not defined"
    And the missing location information for options, are displayed with "Location not defined"

  @personas @javascript @browser @problematic
  Scenario: Content of a picking list before hand over -- unavailable items
    Given there is a hand over with at least one problematic line
    And I open the hand over
    And a line has no item assigned yet and this line is marked
    When I open the picking list
    Then the lists are sorted by hand over date
    And the unavailable items are displayed with "Not available"

  @personas @javascript @browser
  Scenario: Content of a picking list before hand over -- Unassigned room and shelf
  Given there is a hand over with at least an item without room or shelf
    And I open the hand over
    And a line with an assigned item which doesn't have a location is marked
    When I open the picking list
    Then items without assigned room or shelf are shown with "Location not defined"

  @personas @javascript
  Scenario: Inhalt der Rüstliste nach Aushändigung - Inventarcodes sind bekannt
    When I open the picking list for a signed contract
    Then the lists are sorted by take back date
     And each list contains the following columns
     | Column         |
     | Quantity       |
     | Inventory code |
     | Model name     |
     | Room / Shelf   |
     And each list will sorted after room and shelf
     And items without assigned room or shelf are shown with "Location not defined"
     And the missing location information for options, are displayed with "Location not defined"

  @personas @javascript
  Scenario: Wo wird die Rüstliste aufgerufen
  	When I visit the lending section on the list of all contracts
    And I see at least a contract
    Then I can open the picking list of any contract line
    When I visit the lending section on the list of open contracts
    And I see at least a contract
    Then I can open the picking list of any contract line
    When I visit the lending section on the list of closed contracts
    And I see at least a contract
    Then I can open the picking list of any contract line
    When I open a hand over which has multiple reservations
    And I select at least one line
    Then I open the picking list
