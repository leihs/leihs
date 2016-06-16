
Feature: Explorative search

  Background:
    Given I am Normin

  @personas
  Scenario: Explorative search in model list
    Given I am listing models
    Then I see the explorative search
    And it contains the currently selected category's direct children and their children
    And those categories and their children that do not contain any borrowable items are hidden

  @personas
  Scenario: Choosing a subcategory
    Given I am listing models
    When I choose a category
    Then the models of the currently chosen category are shown

  @personas
  Scenario: Reaching the outermost branch/a leaf of the tree
    Given I am in the model list viewing a category without children
    Then the explorative search panel is not visible and the model list is expanded
