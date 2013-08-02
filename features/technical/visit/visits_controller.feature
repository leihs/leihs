Feature: Visits controller

  Background:
    Given personas existing
    And I log in as 'pius' with password 'password'
    And test data setup for "Hand over controller" feature

  Scenario: Index action provides take backs by specific date
    When the index action of the visits controller is called with the filter parameter "take back" and a given date
    Then the result of this action are all take back visits for the given inventory pool and the given date

  Scenario: Index action provides hand overs by specific date
    When the index action of the visits controller is called with the filter parameter "hand over" and a given date
    Then the result of this action are all hand over visits for the given inventory pool and the given date
