Feature: calendar

  In order to view the availability of a model
  As a customer
  I want to view the calendar of a model

  Background:
    Given I am Normin

  @personas @javascript @browser
  Scenario: reached maximum amount of visits of a week day
    When I open the calendar of a model related to an inventory pool for which has reached maximum amount of visits
    And I select that inventory pool
    Then no availability number is shown on this specific date
    When I specify this date as start date
    Then the start date becomes red and I see a not possible day warning
    And I receive an error message within the modal
    When I specify this date as end date
    Then the end date becomes red and I see a not possible day warning
    And I receive an error message within the modal
    When I save the booking calendar
    Then I receive an error message within the modal
    And the booking calendar is not closed

  @personas @javascript @browser
  Scenario: hand over not possible according to days between submission and hand over
    When I open the calendar of a model related to an inventory pool for which the number of days between order submission and hand over is defined as 2
    And I select that inventory pool
    Then no availability number is shown for today
    And no availability number is shown for tomorrow
    And the availability number is shown for the next open day after tomorrow
    When I specify today as start date
    Then the start date becomes red and I see a too early day warning
    When I specify tomorrow as start date
    Then the start date becomes red and I see a too early day warning
    When I save the booking calendar
    Then I receive an error message within the modal
    And the booking calendar is not closed
