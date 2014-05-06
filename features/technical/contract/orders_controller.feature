Feature: Orders controller

  Background:
    Given personas existing
    And I log in as 'pius' with password 'password'
    And test data setup for "Orders controller" feature

  Scenario: Index action provides all submitted/pending contracts
    When the index action of the contracts controller is called with the filter parameter "submitted"
    Then the result of this action are all submitted contracts for the given inventory pool
