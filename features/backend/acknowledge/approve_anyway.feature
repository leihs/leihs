Feature: Approve anyway

  In order to approve a contract
  As a Lending Manager
  I want to have functionalities to approve a contract even if there are conflicts/problems

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Approve anyway on daily view
    Given I open the daily view
      And I try to approve a contract that has problems
     Then I got an information that this contract has problems
     When I approve anyway
     Then this contract is approved
      
