Feature: Select reservations or linegroups

  In order to manage multiple reservations
  As a backend user
  I want to be able select multiple reservations at once

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Select multiple reservations
     When I open a take back, hand over or I edit a contract 
      And I select all reservations of an linegroup
     Then the linegroup is selected
      And the count matches the amount of selected reservations
     When I open a take back
      And I select the linegroup 
     Then all reservations of that linegroup are selected
      And the count matches the amount of selected reservations
