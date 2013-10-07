Feature: Submit contract

  Model test

  Background:
    Given personas existing
    And an inventory pool existing
    And a contract with lines existing

  Scenario: Submitting a contract is creating a purpose associated to the lines
    When the contract is submitted with the purpose description "Some purpose description"
    Then each line associated with the contract must have the same purpose description
