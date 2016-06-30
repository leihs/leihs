Feature: Templates

  Background:
    Given the basic dataset is ready

  @templates
  Scenario: Assign an Article
    Given I am Barbara
    When I navigate to the templates page
    Then I see all main categories of the sub categories I am assigned to
    And the main categories are collapsed
    When I expand the main categories
    Then I see all sub categories I am assigned to
    When I add a new template
    And I fill in the following fields
      | Article or Project          |
      | Article nr. or Producer nr. |
      | Price                      |
      | Supplier                   |
    And I click on save
    Then I see a success message
    And the data entered is saved to the database

  @templates
  Scenario: Deleting an Article
    Given I am Barbara
    And a sub category which I'm inspector exists
    And the sub category contains template articles
    When I navigate to the templates page
    And I delete one of the template articles
    Then this article is marked red
    When I click on save
    Then I see a success message
    And the article is deleted from the database

  @templates
  Scenario: Modify a Template
    Given I am Barbara
    And a sub category which I'm inspector exists
    And the category has one template article
    And the template is already used in many requests
    When I navigate to the templates page
    And the following fields are modified
      | Article or Project          |
      | Article nr. or Producer nr. |
      | Price                      |
      | Supplier                   |
    And I click on save
    Then I see a success message
    And the data modified is saved to the database
    And the requests references are not nullified

  @templates
  Scenario: Deleting information of some fields of an article
    Given I am Barbara
    And a sub category which I'm inspector exists
    And the category has one template article
    When I navigate to the templates page
    And the following fields are filled
      | Article or Project          |
      | Article nr. or Producer nr. |
      | Price                      |
      | Supplier                   |
    When I delete the following fields
      | Article nr. or Producer nr. |
      | Price                      |
      | Supplier                   |
    And I click on save
    Then I see a success message
    And the data is deleted from the database
    When I delete the following fields
      | Article or Project          |
    Then the field "article" is marked red
    And I can not save

  @templates
  Scenario: Sorting of categories and articles
    Given I am Barbara
    And several main categories exist
    And several sub categories exist
    And several template articles in sub categories exist
    When I navigate to the templates page
    Then the categories are sorted 0-10 and a-z
    And the articles inside a sub category are sorted 0-10 and a-z

  @templates
  Scenario: Searching a category or an article
    Given I am Barbara
    And several categories exist
    And several template articles in sub categories exist
    When I navigate to the templates page
    And I type a search string into the search field
    Then all main categories where the name of the main category matches the search string are shown
    And all sub categories are expanded where the name of the sub category matches the search string
    And all sub categories are expanded which contain article names matching the search string
    When I delete the search string
    Then all categories and all articles are listed again
