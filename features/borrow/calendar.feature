Feature: calendar

  In order to view the availability of a model
  As a customer
  I want to view the calendar of a model

  Background:
    Given I am Normin

  @upcoming
  Scenario: reached maximum amount of visits of a week day
  Given the maximum amount of visits of a date has been reached
  When I open the calendar of a model
  Then no amount is shown on this specific date
  When I specify this date as start or end date 
  Then the day is marked red
  And I receive an error message



