
Feature: Start page

  @personas
  Scenario: Start page
    Given I am Normin
    And there exists a main category with own image
    And there exists a main category without own image but with a model with image
    And I am listing the root categories
    Then I see exactly those root categories that are useful for my user
    And I see for each category its image, or if not set, the first image of a model from this category
    When I choose a root category
    Then I see the model list for this root category

  @javascript @personas
  Scenario: Expanding root categories
    Given I am Normin
    And I am listing the root categories
    When I hover over a main category with children
    Then I see only this root category's children that are useful and available to me
    When I choose one of these child categories
    Then I see the model list for this category

  @personas
  Scenario: Child categories not visible in the dropdown
    Given I am Normin
    And I am listing the root categories
    And there is a root category whose child categories cannot offer me any items
    Then that root category has no child category dropdown
