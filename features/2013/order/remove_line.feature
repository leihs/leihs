Feature: Remove line

  Test on model level

  Background:
    Given there is an inventory pool

  Scenario: Removal of a line for UNSUBMITTED order should be possible
    Given there is a "UNSUBMITTED" order with at least 2 lines
    When one tries to delete a line
    Then then the line is deleted
    And the amount of lines decreases by one

  Scenario: Removal of a line for SUBMITTED order should be possible
    Given there is a "SUBMITTED" order with at least 2 lines
    When one tries to delete a line
    Then then the line is deleted
    And the amount of lines decreases by one

  Scenario: Removal of a line for APPROVED order should NOT be possible
    Given there is a "APPROVED" order with at least 2 lines
    When one tries to delete a line
    Then then the line is NOT deleted
    And the amount of lines remains unchanged

  Scenario: Removal of a line for REJECTED order should NOT be possible
    Given there is a "REJECTED" order with at least 2 lines
    When one tries to delete a line
    Then then the line is NOT deleted
    And the amount of lines remains unchanged

  Scenario: Removal of last line of an order should not be possible
    Given there is an order with a single line
    Then removal of this line should not be possible
