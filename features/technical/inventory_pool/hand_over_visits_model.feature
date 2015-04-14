Feature: Hand over visits

  Model test

  Background:
    Given inventory pool model test data setup
    And all contracts and contract lines are deleted

  Scenario: Inventory pool returns a list of hand over visits per user
    Given there are open contracts for all users
    And every contract has a different start date
    And there are hand over visits for the specific inventory pool
    When all the contract lines of all the events are combined
    Then the result is a set of contract lines that are associated with the users' contracts

  Scenario: Inventory pool should return a visit containing contract_lines for items that are reserved from the same day on by a user
    Given there is an open contract with lines for a user
    And the first contract line starts on the same date as the second one
    And the third contract line starts on a different date as the other two
    When the visits of the inventory pool are fetched
    Then the first two contract lines should now be grouped inside the first visit, which makes it two visits in total

  Scenario: Inventory pool should not mix visits of different users
    Given there are 2 different contracts for 2 different users
    Then there are 2 hand over visits for the given inventory pool
    Given 1st contract line of 2nd contract has the same start date as the 1st contract line of the 1st contract
    And 1st contract line of 2nd contract has the end date 2 days ahead of its start date
    Then there should be different visits for 2 users with same start and end date
