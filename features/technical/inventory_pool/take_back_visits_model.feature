Feature: Take back visits

  Model test

  Background:
    Given inventory pool model test data setup
    And all contracts and contract reservations are deleted

  Scenario: Inventory pool should return a list of take back visits per user
    Given there are open contracts for all users
    And make sure no end date is identical to any other
    And to each contract line an item is assigned
    And all contracts are signed
    When the take back visits of the given inventory pool are fetched
    Then there should be as many events as there are different start dates
    When all the contract reservations of all the visits are combined
    Then one should get the set of contract reservations that are associated with the users' contracts

  Scenario: Inventory pool should return a visit containing contract reservations for items reserved from the same day on by a user
    Given there is an open contract with reservations for a user
    And 1st contract line ends on the same date as 2nd
    And 3rd contract line ends on a different date than the other two
    And to each contract line of the user's contract an item is assigned
    And the contract is signed
    When the take back visits of the given inventory pool are fetched
    Then the first 2 contract reservations should be grouped inside the 1st visit, which makes it two visits in total

  Scenario: Inventory pool should not mix visits of different users
    Given there are 2 different contracts with reservations for 2 different users
    And 1st contract line of 2nd contract has the same end date as the 1st contract line of the 1st contract
    And to each contract line of both contracts an item is assigned
    And both contracts are signed
    When the take back visits of the given inventory pool are fetched
    Then the first 2 contract reservations should now be grouped inside the 1st visit, which makes it 2 visits in total
