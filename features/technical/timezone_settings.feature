Feature: Configuring the system timezone through the database
  As a system administrator
  I want to set up my leihs instance to use times from my own timezone
  so that times are represented in a way that makes sense for my users.

  Background:
    Given a settings object

  Scenario: Configuring leihs' time zone to be UTC
    When leihs' time zone is set to "UTC"
    Then ActiveSupport thinks the time zone is "UTC"
    And Time.zone is "(GMT+00:00) UTC"

  Scenario: Configuring leihs' time zone to be CET
    When leihs' time zone is set to "CET"
    Then ActiveSupport thinks the time zone is "CET"
    And Time.zone is "(GMT+01:00) CET"

  Scenario: Representing a date and time on automatically managed time fields (created_at)
    When leihs' time zone is set to "UTC"
    And a record with created_at is created
    Then that record's created_at is in the "(GMT+00:00) UTC" time zone
    Then that record's created_at is in the "(GMT+00:00) UTC" time zone when using in_time_zone
    When leihs' time zone is set to "CET"
    And a record with created_at is created
    Then that record's created_at is in the "(GMT+01:00) CET" time zone
    Then that record's created_at is in the "(GMT+01:00) CET" time zone when using in_time_zone
