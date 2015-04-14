Feature: Assign items during hand over

  In order to assign items to lines of a contract
  As a lending manager
  I want to be able to have functionlities to assign items

  Background:
    Given I am Pius

  @javascript @personas @browser
  Scenario: Assign an inventory code to an itemline
     When I open a hand over which has multiple unassigned lines and models in stock
      And I click an inventory code input field of an item line
     Then I see a list of inventory codes of items that are in stock and matching the model
     When I select one of those
     Then the item line is assigned to the selected inventory code

  # CI-ISSUE: cannot be reproduced with live data in development mode, but with the test data in test mode yes. Seems to be some subtle bug, happening sporadically, possibly having something to do with ajax requests, rendering and timing.
   @javascript @personas
  Scenario: Assign an inventory code by providing an inventory code of an item and a set of selected lines
     When I open a hand over which has multiple unassigned lines and models in stock
      And I select a linegroup
      And I add an item which is matching the model of one of the selected unassigned lines to the hand over by providing an inventory code
     Then the first itemline in the selection matching the provided inventory code is assigned
      And no new line is added to the hand over

  @javascript @personas @browser
  Scenario: Remove the assignment of an inventory code by clear the the inventory code input
     When I open a hand over with lines that have assigned inventory codes
      And I clean the inventory code of one of the lines
     Then the assignment of the line to an inventory code is removed
