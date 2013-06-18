Feature: Delete lines of an open order

  In order to modify an open order
  As a lending manager
  I want to be able to delete single or multiple lines

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Delete a single line of an open order
     When I open an order for acknowledgement that has more then one line
      And I delete a line of this order
     Then this orderline is deleted

  @javascript
  Scenario: Delete multiple lines of an open order
     When I open an order for acknowledgement with more then one line
      And I delete multiple lines of this order
     Then these orderlines are deleted

  @javascript
  Scenario: Delete all lines of an open order
     When I open an order for acknowledgement with more then one line
      And I delete all lines of this order
     Then I got an error message that not all lines can be deleted
      And none of the lines are deleted