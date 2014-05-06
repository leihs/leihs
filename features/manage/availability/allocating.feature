Feature: Allocating of capacities inside the availability

  In order to not struggle with availabilites
  As a Lending Manager
  I want that the application allocates capacities correctly

  Background:
    Given I am "Pius"

  Scenario: Splitting capacities (Group General / Another Group)
    Given a model that has capacities for a group and group general
      And a user that is in that group
     When the user orders the sum of his group and group general
     Then this contract should be allocated in the group and the group general
      And the quantity should be available for that contract

  Scenario: Allocating should be always the same
   Given a list of changes/availabilities
    When I request that list multiple times the allocation of the lines should always be the same
