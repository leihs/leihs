Feature: Edit contract line during hand over process

  In order to edit a contract line
  As an Lending Manager
  I want to have functionalities to change a contract lines time range and quantity

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Change the time range of a single contract line
     When I open a hand over
      And I change a contract lines time range
     Then the time range of that line is changed
     
  @javascript
  Scenario: Change the quantity of a single contract line (item line)
     When I open a hand over
      And I change a contract lines quantity
     Then the contract line was duplicated
     
  @javascript
  Scenario: Change the time range of multiple contract lines
     When I open a hand over which has multiple lines
      And I change the time range for all contract lines, envolving option and item lines
     Then the time range for all contract lines is changed
     
 