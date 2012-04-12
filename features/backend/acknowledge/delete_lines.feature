Feature: Delete lines of an open order

  In order to modify an open order
  As a lending manager
  I want to be able to delete single or multiple lines

  @javascript
  Scenario: Delete a single line of an open order
    Given I am "Pius"
     When I open an order for acknowledgement
      And I delete a line of this order
     Then this orderline is deleted

  @javascript
  Scenario: Delete multiple lines of an open order
    Given I am "Pius"
     When I open an order for acknowledgement with multiple lines
      And I delete multiple lines of this order
     Then these orderlines are deleted