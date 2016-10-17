Feature: Remove line

  Model test

  Background:
    Given required test data for contract tests existing

  @personas
  Scenario: Removal of a line for UNSUBMITTED contract should be possible
    Given there is a "UNSUBMITTED" contract with 2 reservations
    When one tries to delete a line
    Then that line has been deleted
    And the amount of reservations decreases by one

  @personas
  Scenario: Removal of a line for SUBMITTED contract should be possible
    Given there is a "SUBMITTED" contract with 2 reservations
    When one tries to delete a line
    Then that line has been deleted
    And the amount of reservations decreases by one

  @personas
  Scenario: Removal of a line for APPROVED contract should be possible
    Given there is a "APPROVED" contract with 2 reservations
    When one tries to delete a line
    Then that line has been deleted
    And the amount of reservations decreases by one

  @personas
  Scenario: Removal of a line for REJECTED contract should NOT be possible
    Given there is a "REJECTED" contract with 2 reservations
    When one tries to delete a line
    Then that line has NOT been deleted
    And the amount of reservations remains unchanged

  @personas @problematic
  Scenario: Removal of a line for SIGNED contract should NOT be possible
    Given there is a "SIGNED" contract with reservations
    When one tries to delete a line
    Then that line has NOT been deleted
    And the amount of reservations remains unchanged

  @personas @problematic
  Scenario: Removal of a line for CLOSED contract should NOT be possible
    Given there is a "CLOSED" contract with reservations
    When one tries to delete a line
    Then that line has NOT been deleted
    And the amount of reservations remains unchanged

  @personas
  Scenario: Removal of last line of a contract should also remove the contract
    Given there is a "SUBMITTED" contract with 1 reservation
    When one tries to delete a line
    Then that line has been deleted
    And the amount of reservations decreases by one
    And that contract has been deleted
