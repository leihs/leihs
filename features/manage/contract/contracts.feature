Feature: List of contracts

  Background:
    Given I am Andi

  @personas @javascript
  Scenario: Visible tabs
    When I open the tab "Contracts"
    Then I see the tabs:
      | All    |
      | Open   |
      | Closed |
    And the checkbox "To be verified" is already checked and I can uncheck

  @personas @javascript
  Scenario: View contracts
    When I open the tab "Contracts"
    Then I can view "open" contracts
    And I can view "closed" contracts
    And I can view "all" contracts
    And I can open the contract of any contract line
    And I can open the picking list of any contract line
    And I can open the value list of any contract line
