Feature: Reject Order

  In order to reject contracts
  As a Lending Manager
  I want to have functionalities on a submitted contract line

  Background:
    Given Das System ist für den Mailversand im Testmodus konfiguriert
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

  Scenario: Reject a contract on the edit view
    When I open the daily view
    And I edit a submitted contract
    And I reject the contract
    And I can write a reason why I reject that contract
    When I reject the contract
    Then the contract is rejected
    And I am redirected to the daily view
