Feature: Admin users

  Background:
    Given I am Gino

  @personas
  Scenario: Give admin rights to another user (as administrator)
    Given I am editing a user that has no access rights and is not an admin
    When I assign the admin role to this user
    And I save
    Then I see a confirmation of success on the list of users
    And this user has the admin role
    And all their previous access rights remain intact

  @personas
  Scenario: Remove admin rights from a user, as administrator
    Given I am editing a user who has the admin role and access to inventory pools
    When I remove the admin role from this user
    And I save
    Then this user no longer has the admin role
    And all their previous access rights remain intact

  @personas
  Scenario: Add a new user as an administrator, from outside the inventory pool
    Given I am looking at the user list outside an inventory pool
    When I navigate from here to the user creation page
    And I enter the following information
      | First name       |
      | Last name        |
      | E-Mail         |
    And I enter the login data
    And I save
    Then I am redirected to the user list outside an inventory pool
    And I receive a notification
    And the new user has been created
    And he does not have access to any inventory pools and is not an administrator

  @personas
  Scenario: Alphabetic sort order of users outside an inventory pool
    Given I am looking at the user list outside an inventory pool
    # What's here? We need to confirm that A comes before B in the list

  @javascript @personas
  Scenario: Deleting a user as an administrator
    Given I am looking at the user list outside an inventory pool
    And I pick a user without access rights, orders or contracts
    When I delete that user from the list
    Then that user has been deleted from the list
    And that user is deleted

  @personas
  Scenario: Access user list within inventory pool inventory pool as an administrator
    Given I do not have access as manager to any inventory pools
    When I am looking at the user list in any inventory pool
    Then I am redirected to the login page
