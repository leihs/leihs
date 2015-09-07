Feature: Reject Order

  In order to reject contracts
  As a Lending Manager
  I want to have functionalities on a submitted contract line

  Background:
    Given the system is configured for the mail delivery as test mode
    Given I am Pius

  @javascript @personas @browser
  Scenario: Reject a contract on the daily view
    When I navigate to the open orders
     And I reject a contract
    Then I see a summary of that contract
     And I can write a reason why I reject that contract
    When I confirm the contract rejection
    Then the contract is rejected

  @javascript @personas @browser
  Scenario: Reject a contract on the edit view
    When I navigate to the open orders
    And I open a contract for acknowledgement
    And I reject this contract
    Then I see a summary of that contract
    And I can write a reason why I reject that contract
    When I confirm the contract rejection
    Then I am redirected to the daily view
    And the contract is rejected
