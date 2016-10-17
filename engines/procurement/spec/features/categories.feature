Feature: Procurement Categories

  @categories
  Scenario: Creating the main categories
    Given I am Hans Ueli
    And a budget period exist
    And an upcoming budget period exists
    When I navigate to the categories page
    And I click on the add button
    And I fill in the main category name
    And I fill in the budget limit for the current budget period
    And I fill in the budget limit for the upcoming budget period
    And I upload a picture
    And I click on save
    Then I see a success message
    And I stay on the main categories edit page
    And the new main category appears in the list
    And the new main category was created in the database
    When I add a new main category
    And I fill in the main category name
    And I do not save
    And I navigate to the users page, confirming to leave the page
    Then I am navigated to the users page
    And the new main category is not saved to the database

  @categories
  Scenario: Deleting the picture
    Given I am Hans Ueli
    And a budget period exist
    And a main category with a picture exists
    When I navigate to the categories page
    And I delete the picture of the main category
    And I click on save
    Then I see a success message
    And the picture was deleted in the database
    And the default picture of the category is used

  @categories
  Scenario: Creating the sub categories
    Given I am Hans Ueli
    And a main category exists
    And there exists 2 users to become the inspectors
    When I navigate to the categories edit page
    And I click on the add sub category button
    And I fill in the sub category name
    And I fill in the inspectors' names
    And I add a second sub category
    And I fill in the sub category name
    And I fill in the inspectors' names
    And I click on save
    Then I see a success message
    And I stay on the main categories edit page
    And both new sub category with its inspectors were created in the database

  @categories
  Scenario: Editing a main category
    Given I am Hans Ueli
    And there exists a main category
    And there exists 2 budget limits for the category
    And there exists an extra budget period
    When I navigate to the categories edit page
    And I modify the name
    And I delete a budget limit
    And I add a budget limit
    And I modify a budget limit
    And I click on save
    Then I see a success message
    And I stay on the main categories edit page
    And all the information of the main category was successfully updated in the database
    When I add a new sub category
    And I fill in the sub category name
    And I do not save
    And I navigate to the users page, confirming to leave the page
    Then I am navigated to the users page
    And the new sub category is not saved to the database

  @categories
  Scenario: Editing a sub category
    Given I am Hans Ueli
    And a sub category exists
    And the sub category has an inspector
    When I navigate to the categories edit page
    And I modify the name of the sub category
    And I delete the inspector
    And I add another inspector
    And I click on save
    Then I see a success message
    And I stay on the main categories edit page
    And all the information of the sub category was successfully updated in the database

  @categories
  Scenario: Deleting a main category
    Given I am Hans Ueli
    And there exists a sub category without any requests
    And there exist templates for this sub category
    When I navigate to the categories page
    And I delete the main category
    And I confirm to delete the main and the sub category
    And I click on save
    Then I see a success message
    And I stay on the main categories edit page
    And the sub category is successfully deleted from the database
    And the main category is successfully deleted from the database

  @categories
  Scenario: Deleting a main category with sub categories containing requests not possible
    Given I am Hans Ueli
    And there exists a main category
    And there exists a sub category for this main category
    And there exist requests for this sub category
    When I navigate to the categories page
    Then I can not delete the main category

  @categories
  Scenario: Deleting a sub category without existing requests
    Given I am Hans Ueli
    And there exists a sub category without any requests
    And there exist templates for this sub category
    When I navigate to the categories page
    And I delete the sub category
    Then the sub category turns red
    When I click on save
    Then the sub category disappears
    And the sub category is successfully deleted from the database
    And the templates are sucessfully deleted from the database

  @categories
  Scenario: Deleting a sub category with existing requests not possible
    Given I am Hans Ueli
    And there exists a sub category
    And there exist requests for this sub category
    When I navigate to the categories page
    Then I can not delete the main category

  @categories
  Scenario: Sorting of categories
    Given I am Hans Ueli
    And 3 main categories exist
    And each main category has two sub categories
    And I navigate to the categories page
    Then the main categories are sorted 0-10 and a-z
    And the sub categories are sorted 0-10 and a-z

  @categories
  Scenario: Overview of the categories
    Given I am Hans Ueli
    And there exists a main category
    When I navigate to the categories page
    Then the main category line contains the name of the category
    And the sub category line contains the name of the category
    And the sub category line contains the names of the inspectors

  @categories
  Scenario: main category required fields
    Given I am Hans Ueli
    And there does not exist any category yet
    And a current budget period exists
    When I navigate to the categories page
    And I click on the add button
    And I can not save
    Then the field "name" is marked red
    And the new category has not been created

# is this scenario still valid?
#  @categories
#  Scenario: sub category required fields
#    Given I am Hans Ueli
#    And there does not exist any category yet
#    And there exist 1 user to become the inspector
#    When I navigate to the categories page
#    And I click on the add button
#    And I start typing the name of the category
#    Then the inspector field turns red
#    When I delete what has been typed
#    And I start typing the inspectors' name
#    Then the mandatory name field turns red
#    When I fill in the inspector's name
#    And I leave the name of the category empty
#    And I click on save
#    Then the name is still marked red
#    And the new category has not been created
