Feature: Send email upon confirmation

  Model test

  Background:
    Given personas existing
    And required test data for order tests existing

  Scenario: A confirmation email should be sent when an order is confirmed
    Given an order with lines existing
    And a borrowing user existing
    And I am "Ramon"
    When I approve the order of the borrowing user
    Then the borrowing user gets one confirmation email
    And the subject of the email is "[leihs] Reservation Confirmation"
