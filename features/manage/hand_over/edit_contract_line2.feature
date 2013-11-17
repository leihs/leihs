Feature: Edit contract line during hand over process

  In order to edit a contract line
  As an Lending Manager
  I want to have functionalities to change a contract lines time range and quantity

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Change the time range of an option line
     When I open a hand over
      And I add an option to the hand over by providing an inventory code and a date range
      And I change the time range for that option
     Then the time range for that option line is changed
     
  @javascript
  Scenario: Change the quantity of an option line
     When I open a hand over
      And I add an option
      And I change the quantity through the edit dialog
     Then the quantity for that option line is changed
     
  @javascript
  Scenario: Change the quantity directly on an option line
     When I open a hand over
      And I add an option
      And I change the quantity right on the line
     Then the quantity for that option line is changed
     When I decrease the quantity again
     Then the quantity for that option line is changed
