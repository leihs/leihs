Feature: Availability Changes in Booking Calendar

  In order to see when a model is available and unavailable
  As a Lending Manager
  I want to see the availability changes in a calendar

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Seeing all availability changes in the booking calendar
    When I open a booking calendar to edit a singe line
    Then I see all availabilities in that calendar, where the small number is the total quantity of that specific date
