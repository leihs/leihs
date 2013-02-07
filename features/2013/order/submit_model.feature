Feature: Submit order

  Model test

  Background:
    Given personas existing
    And an inventory pool existing
    And an order with lines existing

  Scenario: Submitting an order is creating a purpose associated to the lines
    When the order is submitted with the purpose description "Some purpose description"
    Then each line associated with the order must have the same purpose description
