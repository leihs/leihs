Feature: Edit contract line during acknowledge process

  In order to edit a contract line
  As an Lending Manager
  I want to have functionalities to change a contract reservations time range and quantity

  Background:
    Given I am Pius

  @javascript @personas @browser @problematic
  Scenario: Change the time range of a single contract line
    When I open a contract for acknowledgement
    And I change a contract reservations time range
    Then the time range of that line is changed

  @javascript @personas @browser @problematic
  Scenario: Change the quantity of a single contract line
    When I open a contract for acknowledgement
    And I increase a submitted contract reservations quantity
    Then the quantity of that submitted contract line is changed
    When I decrease a submitted contract reservations quantity
    Then the quantity of that submitted contract line is changed

  @javascript @personas @browser
  Scenario: Change the time range of multiple contract reservations
    When I open a contract for acknowledgement with more then one line, whose start date is not in the past
    And I change the time range for multiple reservations
    Then the time range for that reservations is changed

  @javascript @personas @browser
  Scenario: Do multiple things while editing reservations
    When I open a contract for acknowledgement with more then one line
    And I select two reservations
    And I edit the timerange of the selection
    And I close the booking calendar
    And I edit one of the selected reservations
    Then I see the booking calendar

  @javascript @personas @browser
  Scenario: Preserve the quantity when edit multiple reservations
    When I open a contract for acknowledgement with more then one line
    And I change the time range for multiple reservations that have quantity bigger then 1
    Then the quantity is not changed after just moving the reservations start and end date
