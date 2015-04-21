Feature: Send email upon confirmation

  Model test

  Background:
    Given required test data for contract tests existing

  @personas @javascript
  Scenario: A confirmation email should be sent when a contract is confirmed
    Given I am Ramon
    And a submitted contract with lines existing
    When I approve the contract of the borrowing user
    Then the borrowing user gets one confirmation email
    And the subject of the email is "[leihs] Reservation Confirmation"
