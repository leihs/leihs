Feature: Edit contract line during acknowledge process

  In order to edit a contract line
  As an Lending Manager
  I want to have functionalities to change a contract lines time range and quantity

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Change the time range of a single contract line
     When I open a contract for acknowledgement
      And I change a contract lines time range
     Then the time range of that line is changed
     
  @javascript
  Scenario: Change the quantity of a single contract line
     When I open a contract for acknowledgement
      And I increase a submitted contract lines quantity
     Then the quantity of that submitted contract line is changed
     When I decrease a submitted contract lines quantity
     Then the quantity of that submitted contract line is changed

  @javascript
  Scenario: Preserve the quantity when edit multiple lines
    When I open a contract for acknowledgement with more then one line
     And I change the time range for multiple lines that have quantity bigger then 1
    Then the quantity is not changed after just moving the lines start and end date

  @javascript
  Scenario: Change the time range of multiple contract lines
     When I open a contract for acknowledgement with more then one line
      And I change the time range for multiple lines
     Then the time range for that lines is changed
