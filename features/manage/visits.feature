
Feature: Visits

  @javascript @personas
  Scenario: Human-readable display of dates on visits
    Given I am Pius
      And I am listing visits
    Then each visit shows a human-readable difference between now and its respective date
