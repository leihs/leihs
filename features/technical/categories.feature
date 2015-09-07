Feature: Categories

  @personas
  Scenario: Definition of main categories
    Given there is a main category
    Then this category can have children
    And this category has no parents
