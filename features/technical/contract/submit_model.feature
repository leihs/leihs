Feature: Submit contract

  Model test

  Background:
    Given  an inventory pool existing
    And an unsubmitted contract with reservations existing

  @personas
  Scenario: Submitting a contract is creating a purpose associated to the reservations
    When the contract is submitted with the purpose description "Some purpose description"
    Then each line associated with the contract must have the same purpose description
