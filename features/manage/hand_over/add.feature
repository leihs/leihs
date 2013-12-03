Feature: Add lines during hand over

  In order to hand things over and add lines to the contract
  As a lending manager
  I want to be able to have functionlities to add lines

  Background:
    Given personas existing
      And I am "Pius"
     When I open a hand over

  @javascript
  Scenario: Add an item to the hand over providing an inventory code
      And I add an item to the hand over by providing an inventory code and a date range
     Then the item is added to the hand over for the provided date range and the inventory code is already assigend
     
  @javascript
  Scenario: Add an option to the hand over providing an inventory code
      And I add an option to the hand over by providing an inventory code and a date range
     Then the option is added to the hand over
     
  @javascript
  Scenario: Increase the quantity of an option of the hand over by adding an option providing an inventory code
      And I add an option to the hand over which is already existing in the selected date range by providing an inventory code
     Then the existing option quantity is increased
