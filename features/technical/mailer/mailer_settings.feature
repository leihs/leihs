Feature: Configuring ActionMailer from the database
  As a system administrator
  I want to set up my leihs instance to use all sorts of email setups,
  different servers, ports, authentication etc.
  So that my leihs instance can send email.

  Background:
    Given a settings object

  Scenario: Configuring ActionMailer for test mode through the database
    When the mail delivery method is set to "test"
    Then ActionMailer's delivery method is "test"

  Scenario: Configuring ActionMailer to use sendmail 
    When the mail delivery method is set to "sendmail"
    Then ActionMailer's delivery method is "sendmail"

  Scenario: Setting SMTP authentication
    When the mail delivery method is set to "smtp"
    And the SMTP username is set to "user"
    And the SMTP password is set to "password"
    Then ActionMailer's delivery method is "smtp"
    And ActionMailer's SMTP username is "user"
    And ActionMailer's SMTP password is "password"

  Scenario: Forgetting to specify password when specifying SMTP username (we cleverly rescue this)
    When the mail delivery method is set to "smtp"
    And the SMTP username is set to "user"
    Then ActionMailer's delivery method is "smtp"
    And ActionMailer's SMTP username is nil
    And ActionMailer's SMTP password is nil

  Scenario: Forgetting to specify username when specifying SMTP password (we cleverly rescue this)
    When the mail delivery method is set to "smtp"
    And the SMTP password is set to "password"
    Then ActionMailer's delivery method is "smtp"
    And ActionMailer's SMTP username is nil
    And ActionMailer's SMTP password is nil

