Feature: Sending email for orders placed by a delegation

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Approval email for a delegation's order
    Given there is an order for a delegation that was not placed by a person responsible for that delegation
    When I edit the order
    And I approve the order
    Then I receive a notification of success
    And the approval email is sent to the orderer
    And the approval email is not sent to the delegated user

  @javascript @personas
  Scenario: Reminder email for a delegation's order
    Given there is an overdue take back for a delegation that was not placed by a person responsible for that delegation
    When I send a reminder for this take back
    Then the reminder is sent to the one who picked up the order
    And the approval email is not sent to the delegated user

  @javascript @personas @browser
  Scenario: Sending email from the client to a delegation
    When I search for a delegation
    And I choose the mail function
    Then the email is sent to the delegator user
