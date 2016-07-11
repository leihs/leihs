
# Translating from: features/examples/ausleihe.feature
Feature: Lending

  Background:
    Given I am Pius

  @javascript @browser @personas
  Scenario: Selection during manual interaction when handing over
    When I open a hand over
    And I manually assign an inventory code to an item
    Then the item is selected and the box is checked

  @javascript @browser @personas
  Scenario: Hand over: Highlight items in inventory code lists when they are not available
    When I try to complete a hand over that contains a model with unborrowable items
    And I try to assign an inventory code to this model
    Then the system suggests a list of items
    And unborrowable items are highlighted

  @javascript @personas
  Scenario: When people appear in the last visitors list
    Given I open the daily view
    When I edit an order
    Then the user appears under last visitors
    When I open a hand over
    Then the user appears under last visitors
    When I open a take back
    Then the user appears under last visitors

  @javascript @personas
  Scenario: Error message when trying to hand over something from the future
    When I open a hand over
    And the chosen items contain some from a future hand over
    And I click hand over
    Then I see the error message "you cannot hand out reservations which are starting in the future"
    And I cannot hand over the items

  # https://www.pivotaltracker.com/story/show/29455957
  @javascript @personas
  Scenario: Booking calendar: Show the customer's groups in "show availability"
    Given the customer is in multiple groups
    When I open a hand over to this customer
    And I edit a line containing group partitions
    And I expand the group selector
    Then I see which groups the customer is a member of
    And I see which groups the customer is not a member of

  @javascript @personas
  Scenario: Scanning behavior during hand over
    When I open a hand over for a customer that has things to pick up today as well as in the future
    When I scan something (assign it using its inventory code) and it is already assigned to a future contract
    Then it is assigned (whether it is selected or not)
    When it doesn't exist in any future contracts
    Then it is added for the selected time span

  @javascript @personas @browser
  Scenario: Handing over items and licenses by inventory code
    Given I am doing a hand over
    When I add an item to the hand over by providing an inventory code
    And I add a license to the hand over by providing an inventory code
    And I click on "Hand Over Selection"
    And I fill in all the necessary information in hand over dialog
    And I click on "Hand Over"
    Then there are inventory codes for item and license in the contract

  @javascript @browser @personas @problematic
  Scenario: Handing over items and licenses by model search
    Given I am doing a hand over
    When I add a borrowable item to the hand over by using the search input field
    When I add a borrowable license to the hand over by using the search input field
    And I click on "Hand Over Selection"
    And I fill in all the necessary information in hand over dialog
    And I click on "Hand Over"
    Then there are inventory codes for item and license in the contract

  @javascript @browser @personas @problematic
  Scenario: Inspection during take back
    Given I take back an item
    Then I can inspect each item
    When I inspect an item
    Then I can set the state of "Status" to "Functional" or "Defective"
    And I can set the state of "Completeness" to "Complete" or "Incomplete"
    And I can set the state of "Borrowable" to "Borrowable" or "Unborrowable"
    When I change values during inspection
    And I write a status note
    And I save the inspection
    Then the item is saved with the currently set states

  @javascript @browser @personas
  Scenario: Automatic printing during hand over
    When I open a hand over
    Then the print dialog opens automatically

  @javascript @personas
  Scenario: Default start and end date
    When I open a hand over
    Then start and end date are set to the corresponding dates of the hand over's first time window

  @javascript @personas @browser @problematic
  Scenario: Show all search results
    Given I search for 'a'
    Then I see search results in the following categories:
    | category  |
    | Users     |
    | Models    |
    | Items     |
    | Contracts |
    | Orders    |
    | Options   |
    And I see at most the first 3 results from each category
    When a category has more than 3 results
    Then I can choose to see more results from that category
    When I choose to see more results
    Then I see the first 5 results
    When the category has more than 5 results
    Then I can choose to see all results
    When I choose to see all results, I receive a separate list with all results from this category

  @javascript @personas @browser @problematic
  Scenario: Merging the numbers in an item popup
    Given I navigate to the open orders
    And I hover over the number of items in a line
    Then all these items are listed
    And I see one line per model
    And each line shows the sum of items of the respective model

  @javascript @personas
  Scenario: Clicking the last user after editing an order
    Given I navigate to the open orders
    And I open an order
    Then I return to the daily view
    Then I see the last visitors
    And I see the previously opened order's user as last visitor
    When I click on the last visitor's name
    Then I see search results matching that user's name

  @javascript @personas
  Scenario: Autocomplete during take back
    When I open a take back
    And I enter something in the "Inventory Code/Name" field
    Then I see those items that are part of this take back
    When I assign something that is not part of this take back
    Then I see an error message
    And I see the error message "_for_sure_this_is_not_part_of_the_take_back was not found for this take back"

  @javascript @personas
  Scenario: Selection during manual interaction while taking back
    When I open a take back that contains options
    And I manually change the number of options to return
    Then the option is selected and the box is checked

  @javascript @personas
  Scenario: Searching within orders
    Given orders exist
    When I am listing the orders
    And I search for an order
    Then all listed orders match the search term

  @javascript @personas
  Scenario: Searching purpose within orders
    Given orders exist
    When I am listing the orders
    And I search for an order with its purpose
    Then all listed orders match the search term

  @javascript @personas @problematic
  Scenario: Searching purpose globally
    Given orders exist
    When I search globally for an order with its purpose
    Then all matching orders appear
    Given contracts exist
    When I search globally for a contract with its purpose
    Then all matching contracts appear

  @javascript @personas
  Scenario: Searching within contracts
    Given contracts exist
    When I am listing the contracts
    And I search for a contract
    Then all listed contracts match the search term

  @javascript @personas
  Scenario: Searching purpose within contracts
    Given contracts exist
    When I am listing the contracts
    And I search for a contract with its purpose
    Then all listed contracts match the search term

  @javascript @personas
  Scenario: Searching within visits
    Given visits exist
    When I am listing the visits
    And I search for a visit
    Then all listed visits match the search term
