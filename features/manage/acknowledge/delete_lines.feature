Feature: Delete reservations of an open order

  In order to modify an open contract
  As a lending manager
  I want to be able to delete single or multiple reservations

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Delete a single line of an open contract
    When I open a contract for acknowledgement with more then one line
    And I delete a line of this contract
    Then this reservation is deleted

  @javascript @personas
  Scenario: Delete multiple reservations of an open contract
    When I open a contract for acknowledgement with more then one line
    And I delete multiple reservations of this contract
    Then these reservations are deleted

  @javascript @personas
  Scenario: Delete all reservations of an open contract
    When I open a contract for acknowledgement with more then one line
    And I delete all reservations of this contract
    Then I got an error message that not all reservations can be deleted
    And none of the reservations are deleted
