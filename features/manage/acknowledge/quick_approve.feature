Feature: Quick Approve orders

  In order to approve contracts quickly
  As a Lending Manager
  I want to have quick approve functionalities on the submitted orders

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Quick approve an order with no problems
    Given I navigate to the open orders
    When I quick approve a submitted order
    Then this contract is approved
    And I see a link to the hand over process of that order

  @javascript @personas @browser @problematic
  Scenario: Approve anyway on daily view
    Given I navigate to the open orders
    And the checkbox "No verification required" is already checked and I can uncheck
    And I try to approve a contract that has problems
    Then I got an information that this contract has problems
    When I approve anyway
    Then this contract is approved

