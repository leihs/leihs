Feature: Groups

  Background:
    Given I am Pius
    And I am in the admin area's groups section

  @personas
  Scenario: Anzeige der Gruppenliste
    When I am listing groups
    Then each group shows the number of users assigned to it
    And each group shows how many of each model are assigned to it

  @personas @javascript
  Scenario: Visierungspflichtige Gruppe erstellen
    When I create a group
    And I select 'Yes' for 'Verification required'
    And I fill in the group's name
    And I add users to the group
    And I add models and capacities to the group
    And I save
    Then the group is saved
    And the group requires verification
    And the group has users as well as models and their capacities

  @personas @javascript
  Scenario: Mark a group as requiring verification
    When I edit a group that already exists, which doesn't requires verification
    And I select 'Yes' for 'Verification required'
    And I change the group's name
    And I add and remove users from the group
    And I add and remove models and their capacities from the group
    And I save
    Then the group is saved
    And the group requires verification
    And the group has users as well as models and their capacities
    Then I am listing groups
    And I receive a notification of success

  @personas @javascript
  Scenario: Group does not require verification
    When I edit a group that already exists, which doesn't requires verification
    And I change the group's name
    And I add and remove users from the group
    And I add and remove models and their capacities from the group
    And I save
    Then the group is saved
    And the group doesn't requires verification
    And the group has users as well as models and their capacities
    Then I am listing groups
    And I receive a notification of success

  @javascript @personas
  Scenario: Capacities still available for assignment
    When I create a group
    And I add users to the group
    And I add models and capacities to the group
    Then I see any capacities that are still available for assignment

  @javascript @personas
  Scenario: Deleting groups
    When I delete a group
    # Next step missing
    #And die Gruppe wurde aus der Liste gelöscht
    And the group has been deleted from the database

  @javascript @personas
  Scenario: Adding users
    When I edit a group that already exists
    And I add one user to the group
    Then the user is added to the top of the list

  @javascript @personas
  Scenario: Adding models
    When I edit a group that already exists
    And I add a model to the group
    Then the model is added to the top of the list

  @personas
  Scenario: Sorting models
    When I edit a group that already exists
    Then the already present models are sorted alphabetically

  @javascript @personas
  Scenario: Adding already existing models
    When I edit a group that already exists
    And I add a model that is already present in the group
    Then the model is not added again
    And the already existing model slides to the top of the list
    And the already existing model keeps whatever capacity was set for it

  @javascript @personas
  Scenario: Adding already existing users
    When I edit a group that already exists
    And I add a user that is already present in the group
    Then the already existing user is not added
    Then the already existing user slides to the top of the list

  @personas
  Scenario: Sorting the group list
    When I am listing groups
    Then the list is sorted alphabetically

  @javascript @personas
  Scenario: Creating a group
    When I create a group
    And I fill in the group's name
    And I add users to the group
    And I add models and capacities to the group
    And I save
    Then the group is saved
    And I receive a notification of success
    And the group has users as well as models and their capacities
    When I am listing groups
