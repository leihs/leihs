
Feature: Search

  @personas
  Scenario: Searching for contracts by inventory code of an item that is assigned to a contract
    Given I am Mike
    And I search for the inventory code of an item that is in a contract
    Then I see the contract this item is assigned to in the list of results

  @javascript @personas @browser
  Scenario: Searching for a user that has contracts but no longer has access to the current inventory pool
    Given I am Mike
    And there is a user with contracts who no longer has access to the current inventory pool
    When I search for that user
    Then I see all that user's contracts
    And the name of that user is shown on each contract line
    And that user's personal details are shown in the tooltip

  @javascript @personas
  Scenario: No hand over without approval
    Given I am Pius
    And there is a user with an unapproved order
    When I search for that user
    Then I cannot hand over the unapproved order unless I approve it first

  @javascript @personas
  Scenario: No link to show all matching contracts
    Given I am Mike
    And there is a user with at least 3 and less than 5 contracts
    When I search for that user
    Then I see that user's signed and closed contracts
    Then I don't see a link labeled 'Show all matching contracts'

  @javascript @personas
  Scenario: Displaying retired items
    Given I am Mike
    And there exists a closed contract with a retired item
    When I search globally after this item with its inventory code
    Then I see the item in the items container
    And I hover over the list of items on the contract line
    Then I see in the tooltip the model of this item

  @javascript @personas @browser
  Scenario: Displaying items from another inventory pool in closed contracts
    Given I am Mike
    And there exists a closed contract with an item, for which an other inventory pool is responsible and owner
    When I search globally after this item with its inventory code
    Then I do not see the items container
    And I hover over the list of items on the contract line
    Then I see in the tooltip the model of this item

  @personas @javascript @browser
  Scenario Outline: Showing items' problems in global search
    Given I am Mike
    And there is a "<state>" item in my inventory pool
    When I search globally after this item with its inventory code
    Then I see the item in the items container
    And the item line ist marked as "<state>" in red
    Examples:
      | state        |
      | Broken       |
      | Retired      |
      | Incomplete   |
      | Unborrowable |
