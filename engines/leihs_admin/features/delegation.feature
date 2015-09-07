Feature: Delegation

  @javascript @personas @browser
  Scenario: Delete delegation
    Given I am Gino
    And I can find the user administration features in the "Admin" area under "Users"
    When there is no order, hand over or contract for a delegation
    And that delegation has no access rights to any inventory pool
    Then I can delete that delegation
