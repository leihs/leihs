Feature: calendar

  In order to view the availability of a model
  As a customer
  I want to view the calendar of a model

  Background:
    Given I am Normin

  @upcoming
  Scenario: reached maximum amount of visits of a week day 
  When I open the calendar of a model
  And I select an inventory pool for which the maximum amount of visits of a date has been reached
  Then no availability number is shown on this specific date
  When I specify this date as start or end date 
  Then the day is marked red
  And I receive an error message

  @upcoming
  Scenario: hand over not possible according to days between submission and hand over
  When I open the calendar of a model
  And I select an inventory pool for which the number of days between order submission and hand over is defined as 2
  Then no availability number is shown for today
  And no availability number is shown for tomorrow
  And the availability number is shown for day after tomorrow
  When I specify today as start or end date 
  Then today is marked red
  And I receive an error message
  When I specify tomorrow as start or end date 
  Then tomorrow is marked red
  And I receive an error message
 