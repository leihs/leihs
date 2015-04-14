Feature: Contract sign

  Model test

  @personas
  Scenario: Contract needs at least one contract line with an assigned item
    Given I log in as 'pius' with password 'password'
     When I create an approved contract for "Ramon" with a contract line without an assigned item
     Then there isn't any item associated with this contract line
     When I sign the contract
     Then the contract is still approved
