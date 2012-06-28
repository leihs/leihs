Feature: Edit order line during acknowledge process

  In order to edit an order line
  As an Lending Manager
  I want to have functionalities to change an order lines time range and quantity

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Change the time range of a single order line
     When I open an order for acknowledgement
      And I change an order lines time range
     Then the time range of that line is changed
     
  @javascript
  Scenario: Change the quantity of a single order line
     When I open an order for acknowledgement
      And I change an order lines quantity
     Then the quantity of that line is changed
     
  @javascript
  Scenario: Change the time range of multiple order lines
     When I open an order for acknowledgement with more then one line
      And I change the time range for multiple lines
     Then the time range for that lines is changed
