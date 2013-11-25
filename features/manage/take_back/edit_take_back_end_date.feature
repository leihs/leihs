Feature: Edit take back end date

  In order to extend the lending time of a customer
  As an Lending Manager
  I want to have functionalities to change a take backs end date

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Change the time range of a single take back line
     When I open a take back
      And I change a contract lines end date
     Then the end date of that line is changed
     
  @javascript
  Scenario: Change the time range of multiple contract lines
     When I open a take back which has multiple lines
      And I change the end date for all contract lines, envolving option and item lines
     Then the end date for all contract lines is changed
