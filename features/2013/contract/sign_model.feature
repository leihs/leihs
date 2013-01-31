Feature: Contract sign

  Model test

  Background:
    Given personas existing

  Scenario: Contract needs at least one contract line
    Given I am "Pius"
     When I create an unsigned contract for "Ramon"
     Then the new contract is empty
     When I sign the contract
     Then the contract is unsigned

  Scenario: Contract needs at least one contract line with an assigned item
    Given I am "Pius"
     When I create an unsigned contract for "Ramon"
      And I add a contract line without an assigned item to the new contract
     Then there isn't any item associated with this contract line
     When I sign the contract
     Then the contract is unsigned
