
Feature: Categories

  Background:
    Given I am Mike
    And I open the inventory

  @javascript @personas
  Scenario: Creating top-level categories
    When I open the category list
    And I create a new category
    And I give the category a name
    And I save
    Then the category has been created with the specified name

  @javascript @personas
  Scenario: Displaying categories
    When I open the category list
    Then I see the list of categories
    And the categories are ordered alphabetically
    And the first level is displayed on top
    And I can expand and collapse subcategories

  @javascript @personas
  Scenario: Edit categories
    When I edit a category
    And I change the name and the parents
    And I save
    Then the values are saved

  @javascript @personas
  Scenario: Deleting categories
    When a category has no models
    When I delete the category
    Then the category and all its aliases are removed from the tree
    And I see the list of categories

  @javascript @personas
  Scenario: Can't delete a category if it contains models
    When a category has models
    Then it's not possible to delete the category

  @javascript @browser @personas
  Scenario: Assigning models to a category
    When I edit the model
    And I assign categories
    And I save
    Then I see the notice "Model saved"
    And the categories are assigned

  @javascript @browser @personas
  Scenario: Removing categories
    When I edit the model
    And I remove one or more categories
    And I save
    Then the categories are removed and the model is saved

  @javascript @browser @personas
  Scenario: Category search
    When I search for a category by name
    Then I find categories whose names contain the search term
    And the search results are ordered alphabetically
    And I can edit these categories

  @javascript @browser @personas
  Scenario: Finding and deleting categories without models
    When I search for a category without models by name
    Then I find categories whose names contain the search term
    And I can delete these categories

  @personas
  Scenario: Categories
    When I see the categories

  @javascript @personas @browser
  Scenario: Creating categories
    When I open the category list
    And I create a new category
    And I give the category a name
    And I define parent categories and their names
    And I add an image
    Then I can not add a second image
    When I save
    Then the category is created with the assigned name and parent categories

  @personas @javascript @browser
  Scenario: Editing categories with an image
    Given there exists a category with an image
    And one edits this category
    When I remove the image
    And I add an image
    And I save
    Then the category was saved with the new image
