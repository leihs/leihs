
Feature: Inventory helper

  Background:
    Given I am Matti

  @personas
  Scenario: Wie man den Helferschirm erreicht
    When I open the inventory
    Then I see a tab where I can change to the inventory helper

  @javascript @personas
  Scenario: Changing the shelf when the location already exists
    Given I am on the inventory helper screen
    And there is an item that shares its location with another
    Then I select the field "Shelf"
    And I set some value for the field "Shelf"
    Then I enter the start of the inventory code of the specific item
    And I choose the item from the list of results
    Then I see all the values of the item in an overview with model name and the modified values are already saved
    And the changed values are highlighted
    And the location of the other item has remained the same

  @javascript @personas
  Scenario: You can't change the responsible department while something is not in stock
    Given I am on the inventory helper screen
    And I edit the field "Responsible department" of an item that isn't in stock and belongs to the current inventory pool
    Then I see an error message that I can't change the responsible inventory pool for items that are not in stock

  @javascript @personas
  Scenario: You can't retire something that is not in stock
    Given I am on the inventory helper screen
    And I retire an item that is not in stock
    Then I see an error message that I can't retire the item because it's already handed over or assigned to a contract

  @javascript @personas @browser
  Scenario: Editing items on the helper screen using a complete inventory code (barcode scanner)
    Given I am on the inventory helper screen
    When I choose all fields through a list or by name
    And I set all their initial values
    Then I scan or enter the inventory code of an item that is in stock and not in any contract
    Then I see all the values of the item in an overview with model name and the modified values are already saved
    And the changed values are highlighted

  @javascript @personas
  Scenario: Required fields
    Given I am on the inventory helper screen
    When "Reference" is selected and set to "Investment", then "Project Number" must also be filled in
    When "Relevant for inventory" is selected and set to "Yes", then "Supply Category" must also be filled in
    When "Retirement" is selected and set to "Yes", then "Reason for Retirement" must also be filled in
    Then all required fields are marked with an asterisk
    When a required field is blank, the inventory helper cannot be used
    And I see an error message
    And the required fields are highlighted in red

  @javascript @personas
  Scenario: Trying to edit an inexistant item through the inventory helper
    Given I am on the inventory helper screen
    And I choose the fields from a list or by name
    And I set their initial values
    Then I scan or enter the inventory code of an item that can't be found
    Then I see an error message

  @javascript @personas
  Scenario: Using autocomplete to edit items on the inventory helper
    Given I am on the inventory helper screen
    And I choose the fields from a list or by name
    And I set their initial values
    Then I start entering an item's inventory code
    And I choose the item from the list of results
    Then I see all the values of the item in an overview with model name and the modified values are already saved
    And the changed values are highlighted

  @javascript @browser @personas
  Scenario: Editing after automatic save
    Given I edit an item through the inventory helper using an inventory code
    When I use the edit feature
    Then I can edit all of this item's values right then and there
    When I save
    Then my changes are saved

  @javascript @personas
  Scenario: Canceling an edit after automatic save
    Given I edit an item through the inventory helper using an inventory code
    When I use the edit feature
    Then I can edit all of this item's values right then and there
    When I cancel
    Then the changes are reverted
    And I see all the values of the item in an overview with model name and the modified values are already saved

  @javascript @personas
  Scenario: You can't edit certain fields for items that are in contracts
    Given I am on the inventory helper screen
    And I edit the field "Model" of an item that is part of a contract
    Then I see an error message that I can't change the model because the item is already handed over or assigned to a contract
