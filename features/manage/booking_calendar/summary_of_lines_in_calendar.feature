Feature: Summary of lines in calendar

  In order to recognize which line gets unavailable in the booking calendar and why
  as InventoryPool manager
  I want to see a summary that provides me informations for this use case

  Background:
    Given I am "Pius"

  @javascript
  Scenario: Automatic update of quantity for line summary in calendar 
    When I open a booking calendar to edit a singe line
     And I change the quantity
    Then the specific line in the summary inside the calendar also updates its quantity
