Feature: Hand over visits

  Model test

  Background:
    Given inventory pool model test data setup

  Scenario: Inventory pool returns a list of hand over visits per user
    Given there are open contracts for all users of a specific inventory pool
    And every contract has a different start date
    And there are hand over visits for the specific inventory pool
    When all the contract lines of all the events are combined
    Then the result is a set of contract lines that are associated with the users' contracts
