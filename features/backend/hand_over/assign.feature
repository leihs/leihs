Feature: Assign items during hand over

  In order to assign items to lines of a contract
  As a lending manager
  I want to be able to have functionlities to assign items

  @javascript
  Scenario: Assign an itemline to the hand over providing an inventory code of an item and a set of selected lines
    Given I am "Pius"
     When I open a hand over
      And I select multiple unassigned item lines
      And I add an item which is matching the model of one of the selected lines to the hand over by providing an inventory code
     Then the first itemline in the selection matching the provided inventory code is assigned
      And no new line is added to the hand over