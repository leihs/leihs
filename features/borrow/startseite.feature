
Feature: Start page

  @personas
  Scenario: Start page
    Given I am Normin
    And there exists a main category with own image
    And there exists a main category without own image but with a model with image
    And I am listing the main categories
    Then I see exactly those main categories that are useful for my user
    And I see for each category its image, or if not set, the first image of a model from this category
    When I enter to a main category
    Then I see the model list for this main category

  @javascript @personas
  Scenario: Expanding main categories
    Given I am Normin
    And I am listing the main categories
    When I hover over a main category with children
    Then I see only this main category's children that are useful and available to me
    When I choose one of these child categories
    Then I see the model list for this category

  @personas
  Scenario: Child categories not visible in the dropdown
    Given I am Normin
    And I am listing the main categories
    And there is a main category whose child categories cannot offer me any items
    Then that main category has no child category dropdown
