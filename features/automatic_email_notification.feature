Feature: Automatic email notification

  Background:
    Given the system is configured for the mail delivery as test mode
    And I am Normin

  @personas
  Scenario: Automatic return notification
    Given I have a non overdue take back
    Then the day before the take back I receive a deadline soon email

  @personas
  Scenario: Automatic return notification if delayed
    Given I have an overdue take back
    Then the day after the take back I receive a remember email
    And for each further day I receive an additional remember email
