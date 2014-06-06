Feature: Add lines

  Model test (instance methods)

  Background:
    Given required test data for contract tests existing

  @personas
  Scenario Outline: Adding lines is successful
    Given an empty contract of <allowed type> existing
    And I log in as 'ramon' with password 'password'
    When I add some lines for this contract
    Then the size of the contract should increase exactly by the amount of lines added

    Examples:
      | allowed type |
      | UNSUBMITTED  |
      | SUBMITTED    |
