Feature: Templates

  Background:
    Given the basic dataset is ready

  @templates
  Scenario: Create a Template Category
    Given I am Barbara
    When I navigate to the templates page
    Then there is an empty category line for creating a new category
    When I enter the category name
    And I click on save
    Then I see a success message
    And the category is saved to the database

  @templates
  Scenario: Create a Template Article
    Given I am Barbara
    And a template category exists
    When I navigate to the templates page
    And I edit the category
    And the following fields are filled
      | Article / Project                    |
      | Article nr. / Producer nr. |
      | Price                      |
      | Supplier                   |
    And I click on save
    Then I see a success message
    And the data entered is saved to the database

  @templates
  Scenario: Deleting a Template Category
    Given I am Barbara
    And a template category exists
    And the template category contains articles
    When I navigate to the templates page
    And I delete the template category
    Then the template category is marked red
    When I click on save
    Then I see a success message
    And the deleted template category is deleted from the database

  @templates
  Scenario: Deleting an Article
    Given I am Barbara
    And a template category exists
    And the template category contains articles
    When I navigate to the templates page
    And I edit the category
    And I delete an article from the category
    Then the article of the category is marked red
    When I click on save
    Then I see a success message
    And the category article is deleted from the database

  @templates
  Scenario: Editing a Template
    Given I am Barbara
    And a template category exists
    And the template category has one article
    When I navigate to the templates page
    And I edit the category
    And I modify the category name
    And the following fields are modified
      | Article / Project                    |
      | Article nr. / Producer nr. |
      | Price                      |
      | Supplier                   |
    And I click on save
    Then I see a success message
    And the data modified is saved to the database

  @templates
  Scenario: Deleting information of some fields of an article
    Given I am Barbara
    And a template category exists
    And the template category has one article
    When I navigate to the templates page
    And I edit the category
    And the following fields are filled
      | Article / Project                    |
      | Article nr. / Producer nr. |
      | Price                      |
      | Supplier                   |
    When I delete the following fields
      | Article nr. / Producer nr. |
      | Price                      |
      | Supplier                   |
    And I click on save
    Then I see a success message
    And the deleted data is deleted from the database

  @templates
  Scenario: Sorting of categories and articles
    Given I am Barbara
    And several template categories exist
    And several template articles in categories exist
    When I navigate to the templates page
    Then the categories are sorted 0-10 and a-z
    And the articles inside a category are sorted 0-10 and a-z

  @templates
  Scenario: Nullify id in request when articlename and article nr./supplier nr. have been changed
    Given I am Barbara
    And a template category exists
    And the template category has one article
    And the template is already used in many requests
    When I navigate to the templates page
    And I edit the category
    And the following fields are modified
      | Article / Project                    |
      | Article nr. / Producer nr. |
    And I click on save
    Then I see a success message
    And the data modified is saved to the database
    And the requests are nullified
