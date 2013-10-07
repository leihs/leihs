Feature: Select lines or linegroups

  In order to manage multiple lines
  As a backend user
  I want to be able select multiple lines at once

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Select multiple lines
     When I open a take back, hand over or I edit a contract 
      And I select all lines of an linegroup
     Then the linegroup is selected
      And the count matches the amount of selected lines
     When I open a take back
      And I select the linegroup 
     Then all lines of that linegroup are selected
      And the count matches the amount of selected lines
