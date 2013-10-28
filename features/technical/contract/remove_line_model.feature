Feature: Remove line

  Model test

  Background:
    Given required test data for contract tests existing

  Scenario: Removal of a line for UNSUBMITTED contract should be possible
    Given there is a "UNSUBMITTED" contract with 2 lines
    When one tries to delete a line
    Then the line is deleted
    And the amount of lines decreases by one

  Scenario: Removal of a line for SUBMITTED contract should be possible
    Given there is a "SUBMITTED" contract with 2 lines
    When one tries to delete a line
    Then the line is deleted
    And the amount of lines decreases by one

  Scenario: Removal of a line for APPROVED contract should NOT be possible
    Given there is a "APPROVED" contract with 2 lines
    When one tries to delete a line
    Then the line is deleted
    And the amount of lines decreases by one

  Scenario: Removal of a line for REJECTED contract should NOT be possible
    Given there is a "REJECTED" contract with 2 lines
    When one tries to delete a line
    Then the line is NOT deleted
    And the amount of lines remains unchanged

  Scenario: Removal of a line for SIGNED contract should NOT be possible
    Given there is a "SIGNED" contract with 2 lines
    When one tries to delete a line
    Then the line is NOT deleted
    And the amount of lines remains unchanged

  Scenario: Removal of a line for CLOSED contract should NOT be possible
    Given there is a "CLOSED" contract with 2 lines
    When one tries to delete a line
    Then the line is NOT deleted
    And the amount of lines remains unchanged

  Scenario: Removal of last line of a contract should also remove the contract
    Given there is a "SUBMITTED" contract with 1 line
    When one tries to delete a line
    Then the line is deleted
    And the amount of lines decreases by one
    And the contract is deleted
