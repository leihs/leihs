Feature: Hand over controller

  Assigning inventory code and different visit tests

  Background:
    Given personas existing
    And I log in as 'pius' with password 'password'
    And test data setup for "Hand over controller" feature

  Scenario: Writing an unavailable inventory code
    Given test data setup for scenario "Writing an unavailable inventory code"
    When an unavailable inventory code is assigned to a contract line
    Then the response from this action should not be successful
    And the contract line has no item

  Scenario: Visit that is overdue, should be deleted and respond with success
    Given visit that is overdue
    When the visit is deleted
    Then the response from this action should be successful
    And the visit does not exist anymore

  Scenario: Visit that is in future, should be deleted and respond with success
    Given visit that is in future
    When the visit is deleted
    Then the response from this action should be successful
    And the visit does not exist anymore


