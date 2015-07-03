Feature: Main categories

  @personas
  Scenario: Define main category
    Given there exists a main category
    Then this category can have children categories
    And this category is not child of another category
