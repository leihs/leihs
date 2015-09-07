Feature: Allocating of capacities inside the availability

  In order to not struggle with availabilites
  As a Lending Manager
  I want that the application allocates capacities correctly

  Background:
    Given I am Pius

  @personas
  Scenario: Allocating should be always the same
    Given a list of changes/availabilities
    When I request that list multiple times the allocation of the reservations should always be the same
