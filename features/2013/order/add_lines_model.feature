Feature: Add lines

  Model test (instance methods)

  Background:
    Given personas existing
    And required test data for order tests existing

  Scenario Outline: Adding lines is successful
    Given an empty order of <allowed type> existing
    And I am "Ramon"
    When I add some lines for this order
    Then the size of the order should increase exactly by the amount of lines added

    Examples:
      | allowed type |
      | UNSUBMITTED  |
      | SUBMITTED    |
