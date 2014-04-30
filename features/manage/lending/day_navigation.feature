Feature: Daily View Day Navigation

  In order to have an overview of an specific day
  As a Lending Manager
  I want to have functionalities to switch to a specific day
  
  Background:
    Given personas existing
      And I am "Pius"

  #
  # Scenario: Go to the next day
  
  #
  # Scenario: Go to the previous day
    
  #
  # Scenario: Go to today

  @javascript
  Scenario: Jump to a specific date
    When I open the daily view
     And I open the datepicker
     And I select a specific date
    Then the daily view jumps to that day
    When I open the datepicker
     And I click the open button again
    Then the datepicker closes
