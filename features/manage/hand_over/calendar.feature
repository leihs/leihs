Feature: calendar

  Background:
    Given I am Pius

  @personas @javascript @browser
  Scenario: reached maximum amount of visits of a week day
    Given the current inventory pool has reached maximum amount of visits
    When I open a hand over
    And I open the booking calendar
    Then the availability number is shown on this specific date
    When I specify this date as start date
    Then the start date becomes red and I see a not possible day warning
    And I receive an error message within the modal
    When I specify this date as end date
    Then the end date becomes red and I see a not possible day warning
    And I receive an error message within the modal
    When I save the booking calendar
    Then the booking calendar is closed
    And the start or end date of that line is changed
