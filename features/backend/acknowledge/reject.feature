Feature: Reject Order

  In order to reject contracts
  As a Lending Manager
  I want to have functionalities on a submitted contract line

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Reject a contract on the daily view
    When I open the daily view
     And I reject a contract
    Then I see a summary of that contract
     And I can write a reason why I reject that contract
    When I reject the contract
    Then the contract is rejected
     And the counter of that list is updated
