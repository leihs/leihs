
Feature: Explorative search

  As a user
  In order to discover models in their categories
  I want to be able to browse and search

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Explorative search in the inventory list
    Given I open the inventory
    And I open the category filter
    When I select a category
    Then I see that category's children
    And I can select the child category
    And I see the top-level category as well as the currently selected one and its children
    And the inventory I see is filtered by this category
    And I can navigate back to the current top-level category in one single step
    And I can navigate back to the list of top-level categories in one single step
    When I collapse the category filter
    Then I see only the list of inventory

  @javascript @personas
  Scenario: Find a category using explorative search
    Given I open the inventory
    And I open the category filter
    When I search for a category name
    Then all categories whose names match the search term are shown
    When I select a category
    Then I see that category's children
    And I can select the child category
    And I see a search indicator with the current search term as well the currently selected category and its children
    And the inventory I see is filtered by this category

  @javascript @personas
  Scenario: Navigating back in the explorative search
    Given I used the explorative search to get to a subcategory
    Then I can navigate to the parent category

  # This is already covered by 'Explorative search in the inventory list', waste of CPU to cover it again
  # For some reason, there are steps talking about models in explorative_suche_steps.rb,
  # but they are never used anywhere?
  #@javascript @personas
  #Scenario: Explorative search in the model list
  #  Given I open the inventory
  #  And I open the category filter
  #  And I select a category
  #  Then I see that category's children
  #  And I can select the child category
  #  And I see the top-level category as well as the currently selected one and its children
  #  And the inventory I see is filtered by this category

  @javascript @personas @browser
  Scenario: Filter not categorized models
    Given I open the inventory
    And I see retired and not retired inventory
    And I open the category filter
    When I select the not categorized filter
    Then I see the models not assigned to any category

  