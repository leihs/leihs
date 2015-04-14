Feature: Take back

  As a lending manager
  To put items back on the shelve so they can be borrowed again
  I want to mark them as back in stock in.

  Background:
  Given I am Pius

  @javascript @personas
  Scenario: Taking back an item
    Given I am taking something back
    When I take back an item using the assignment field
    Then the line is selected
    And the line is highlighted in green
    And I receive a notification of success

  @personas @javascript
  Scenario: Deselecting a line
    Given I am taking something back
    When I take back an item using the assignment field
    And I deselect the line
    Then the line is no longer highlighted in green

  @javascript @personas
  Scenario: Item to return is overdue
    Given I am taking back at least one overdue item
    When I take back an overdue item using the assignment field
    Then the line is highlighted in green
    And the line is selected
    And the problem indicator for the line is displayed
    Then I receive a notification of success

  @javascript @browser @personas
  Scenario: Making a note of who took back an item
    When I open a take back
    And I select all lines of an open contract
    And I click take back
    And I see a summary of the things I selected for take back
    And I click take back inside the dialog
    And the contract is closed and all items are returned
    Then a note is made that it was me who took back the item

  @personas @javascript @browser
  Scenario: Showing whether a user is suspended
    Given I navigate to the open orders
    And I open a suspended user's order
    Then I see the note 'Suspended!' next to their name

  @javascript @personas
  Scenario: Returning an option
    Given I am on a take back with at least two of the same options
    When I take back an option using the assignment field
    Then the line is selected
    And the line is not highlighted in green
    When I take back all options of the same line
    Then the line is highlighted in green
    And I receive a notification of success

  @personas
  Scenario: Correct order for contracts
    Given there is a user with at least 2 take back s on 2 different days
    When I open a take back for this user
    Then the take backs are ordered by date in ascending order

  @javascript @personas
  Scenario: Treating options with multiple time windows
    Given there is a user with an option to return in two different time windows
    And I open a take back for this user
    When I take back this option
    Then the option is added to the first time window
    When the first time window has already reached the maximum quantity of this option
    And I add the same option again
    Then the option is added to the second time window
