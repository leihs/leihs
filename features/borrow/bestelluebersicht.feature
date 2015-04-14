
Feature: Viewing my orders

  Background:
    Given I am Normin
    And I have added items to an order
    When I open my list of orders

  @personas
  Scenario: Listing items in an order
    Then I see entries grouped by start date and inventory pool
    And the models are ordered alphabetically
    And each entry has the following information
    |Image|
    |Quantity|
    |Model name|
    |Manufacturer|
    |Number of days|
    |End date|
    |the various actions|

  @javascript @browser @personas
  Scenario: Deleting things in my order overview
    When I delete an entry
    Then the items are available for borrowing again
     And the entry is removed from the order

  @javascript @personas
  Scenario: Timeout
    Given the timeout is set to 1 minute
    When I add a model to an order
    Then I see a timer
    When I am viewing my current order
    Then I see the timer formatted as "mm:ss"
    When the timer has run down
    Then I am redirected to the timeout page

  @javascript @personas
  Scenario: Changing one of my orders
    When I change the entry
    Then the calendar opens
    When I change the date
    And I save the booking calendar
    Then the entry's date is changed accordingly
    And the entry is grouped based on its current start date and inventory pool

  @javascript @browser @personas
  Scenario: Deleting an order from my order overview
    When I delete the order
    Then I am asked whether I really want to delete the order
    And I am again on the borrow section's start page
    And all entries are deleted from the order
    And the items are available for borrowing again

  @personas
  Scenario: Ordering
    When I enter a purpose
    And I submit the order
    And I reload the order
    Then the order's status changes to submitted
    And I see an order confirmation
    And the order confirmation lets me know that my order will be handled soon
    And I am again on the borrow section's start page

  @personas
  Scenario: Forgetting to fill in the purpose
    When I don't fill in the purpose
    Then I can't submit my order
