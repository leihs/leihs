Feature: Orders controller

  Background:
    Given personas existing
    And I log in as 'pius' with password 'password'
    And test data setup for "Orders controller" feature

  Scenario: Index action provides all submitted/pending orders
    When the index action of the orders controller is called with the filter parameter "pending"
    Then the result of this action are all submitted/pending orders for the given inventory pool
