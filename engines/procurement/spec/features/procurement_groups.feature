Feature: Procurement Groups

  @procurement_groups
  Scenario: Creating the procurement groups
    Given I am Hans Ueli
    And a budget period exist
    And there exists 2 users to become the inspectors
    When I navigate to the groups page
    And I click on the add button
    And I fill in the name
    And I fill in the inspectors' names
    And I fill in the email
    And I fill in the budget limit
    And I click on save
    Then I am redirected to the groups index page
    And the new group appears in the list
    And the new group was created in the database

  @procurement_groups
  Scenario: Sorting of Procurement Groups
    Given I am Hans Ueli
    And 3 groups exist
    And I navigate to the groups page
    Then the procurement groups are sorted 0-10 and a-z

  @procurement_groups
  Scenario: Editing a procurement group
    Given I am Hans Ueli
    And there exists a procurement group
    And there exists 2 budget limits for the procurement group
    And the procurement group has 2 inspectors
    And there exists an extra budget period
    When I navigate to the group's edit page
    And I modify the name
    And I delete an inspector
    And I add an inspector
    And I modify the email address
    And I delete a budget limit
    And I add a budget limit
    And I modify a budget limit
    And I click on save
    Then I am redirected to the groups index page
    And I see a success message
    And all the information of the procurement group was successfully updated in the database

  @procurement_groups
  Scenario: Deleting a procurement group
    Given I am Hans Ueli
    And there exists a procurement group without any requests
    When I navigate to the groups page
    And I delete the group
    Then the group disappears from the list
    And the group was successfully deleted from the database

  @procurement_groups
  Scenario: Overview of the procurement groups
    Given I am Hans Ueli
    And there exists a procurement group
    When I navigate to the groups page
    Then the group line contains the name of the group
    And the group line contains the name of the group's inspectors
    And the group line contains the email of the group

  @procurement_groups
  Scenario: Procurement group required fields
    Given I am Hans Ueli
    And there does not exist any procurement group yet
    And there exist 1 user to become the inspector
    When I navigate to the groups page
    And I click on the add button
    Then I see the name field marked red
    And I fill in the inspectors' names
    And I fill in the email
    And I leave the name empty
    And I click on save
    Then the name is still marked red
    And the new group has not been created
