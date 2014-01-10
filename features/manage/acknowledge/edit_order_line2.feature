Feature: Edit contract line during acknowledge process

  In order to edit a contract line
  As an Lending Manager
  I want to have functionalities to change a contract lines time range and quantity

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Do multiple things while editing lines
    When I open a contract for acknowledgement with more then one line
     And I select two lines
     And I edit the timerange of the selection
     And I close the booking calendar
     And I edit one of the selected lines
    Then I see the booking calendar

  @javascript
  Scenario: Preserve the quantity when edit multiple lines
    When I open a contract for acknowledgement with more then one line
    And I change the time range for multiple lines that have quantity bigger then 1
    Then the quantity is not changed after just moving the lines start and end date
