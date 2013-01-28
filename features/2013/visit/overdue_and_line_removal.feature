Feature: Overdues and line removals (instance methods)

  Scenario: All hand overs with date < today are overdues
    Given personas existing
    And there are "overdue" visits
    Then every visit with date < today is overdue

  Scenario: Remove line
    Given some precondition
     Then is NOT deleting the last line of an SUBMITTED order
