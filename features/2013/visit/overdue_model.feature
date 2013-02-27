Feature: Overdues

  Model test (instance methods)

  Scenario: All hand overs with date < today are overdues
    Given personas existing
    And there are "overdue" visits
    Then every visit with date < today is overdue
