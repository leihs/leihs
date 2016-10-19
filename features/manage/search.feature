
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
    Then I see in the tooltip the model name of this item

  @javascript @personas @browser
  Scenario: Displaying items from another inventory pool in closed contracts
    Given I am Mike
    And there exists a closed contract with an item, for which an other inventory pool is responsible and owner
    When I search globally after this item with its inventory code
    Then I see the item in the items container
    And the items container shows the item line with the following information:
    | Inventory Code             |
    | Model name                 |
    | Responsible inventory pool |
    And I don't see the button group on the item line
    And I hover over the list of items on the contract line
    Then I see in the tooltip the model name of this item

  @personas @javascript @browser @problematic
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

  # this outline split into individual scenarios due to duration of execution
  #
  # @personas @javascript @browser
  # Scenario Outline: Checking the subsection tabs
  #   Given I am Mike
  #   And enough data for "<subsection>" having "search string" exists
  #   When I search globally for "search string"
  #   Then the search results for "search string" are displayed
  #   When I click on the tab named "<subsection>"
  #   Then the first page of results is shown
  #   And I scroll to the end of the list
  #   Then I see all the entries matching "search string" in the "<subsection>"
  #   Examples:
  #     | subsection |
  #     | Models     |
  #     | Software   |
  #     | Items      |
  #     | Licenses   |
  #     | Options    |
  #     | Users      |
  #     | Contracts  |
  #     | Orders     |

  @personas @javascript @browser
  Scenario: Checking the 'Models' subsection tab
    Given I am Mike
    And enough data for "Models" having "search string" exists
    When I search globally for "search string"
    Then the search results for "search string" are displayed
    When I click on the tab named "Models"
    Then the first page of results is shown
    And I scroll to the end of the list
    Then I see all the entries matching "search string" in the "Models"

  @personas @javascript @browser
  Scenario: Checking the 'Software' subsection tab
    Given I am Mike
    And enough data for "Software" having "search string" exists
    When I search globally for "search string"
    Then the search results for "search string" are displayed
    When I click on the tab named "Software"
    Then the first page of results is shown
    And I scroll to the end of the list
    Then I see all the entries matching "search string" in the "Software"

  @personas @javascript @browser
  Scenario: Checking the 'Items' subsection tab
    Given I am Mike
    And enough data for "Items" having "search string" exists
    When I search globally for "search string"
    Then the search results for "search string" are displayed
    When I click on the tab named "Items"
    Then the first page of results is shown
    And I scroll to the end of the list
    Then I see all the entries matching "search string" in the "Items"

  @personas @javascript @browser
  Scenario: Checking the 'Licenses' subsection tabs
    Given I am Mike
    And enough data for "Licenses" having "search string" exists
    When I search globally for "search string"
    Then the search results for "search string" are displayed
    When I click on the tab named "Licenses"
    Then the first page of results is shown
    And I scroll to the end of the list
    Then I see all the entries matching "search string" in the "Licenses"

  @personas @javascript @browser
  Scenario: Checking the 'Options' subsection tabs
    Given I am Mike
    And enough data for "Options" having "search string" exists
    When I search globally for "search string"
    Then the search results for "search string" are displayed
    When I click on the tab named "Options"
    Then the first page of results is shown
    And I scroll to the end of the list
    Then I see all the entries matching "search string" in the "Options"

  @personas @javascript @browser
  Scenario: Checking the 'Users' subsection tabs
    Given I am Mike
    And enough data for "Users" having "search string" exists
    When I search globally for "search string"
    Then the search results for "search string" are displayed
    When I click on the tab named "Users"
    Then the first page of results is shown
    And I scroll to the end of the list
    Then I see all the entries matching "search string" in the "Users"

  @personas @javascript @browser
  Scenario: Checking the 'Contracts' subsection tabs
    Given I am Mike
    And enough data for "Contracts" having "search string" exists
    When I search globally for "search string"
    Then the search results for "search string" are displayed
    When I click on the tab named "Contracts"
    Then the first page of results is shown
    And I scroll to the end of the list
    Then I see all the entries matching "search string" in the "Contracts"

  @personas @javascript @browser
  Scenario: Checking the 'Orders' subsection tabs
    Given I am Mike
    And enough data for "Orders" having "search string" exists
    When I search globally for "search string"
    Then the search results for "search string" are displayed
    When I click on the tab named "Orders"
    Then the first page of results is shown
    And I scroll to the end of the list
    Then I see all the entries matching "search string" in the "Orders"
