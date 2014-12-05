Feature: Closed day alert feature

  In order to recognize that I pick a hand over or take back on a closed day
  As a Lending Manager
  I want to be warned that this day is a closed day

  Background:
    Given I am Pius

  @javascript @browser @personas
  Scenario: Pick a closed day in the calendar
    When I open a booking calendar to edit a singe line
     And I pick a closed day for beeing the start date
    Then the start date becomes red and I see a closed day warning
    When I open a booking calendar to edit a singe line
     And I pick a closed day for beeing the end date
    Then the end date becomes red and I see a closed day warning
