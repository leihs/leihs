Feature: Manage users

  @javascript @personas
  Scenario Outline: Suspend feature for users and delegations
    Given I am inventory manager or lending manager
    And I edit a <user_type>
    When I use the suspend feature
    Then I have to specify a reason for suspension
    And if the <user_type> is suspended, I can remove the suspension
    Examples:
      | user_type |
      | user      |
      | delegation|

  @upcoming @personas
  Scenario: Elements of the edit view
    Given I am inventory manager or lending manager
    And I edit a user
    Then the user's first and last name are used as a title
    And I see the suspend button for this user
    And I see reason and duration of suspension for this user, if they are suspended
    Then I see the following information about the user, in order:
    |en         |de           |
    |Last name  |Name         |
    |First name |Vorname      |
    |Address    |Strasse      |
    |Zip        |PLZ          |
    |City       |Ort          |
    |Country    |Land         |
    |Phone      |Telefonnummer|
    |E-Mail     |E-Mail-Adresse|
    And I can change this user's information, as long as they use local database authentication and not another adapter
    And I cannot change this user's information if they use something other than local database authentication
    And I see the user's role and can change them depending on my own role
    And my changes are saved if I save the user

  @personas
  Scenario: Give admin rights to another user (as administrator)
    Given I am Gino
    And I am editing a user that has no access rights and is not an admin
    When I assign the admin role to this user
    And I save
    Then I see a confirmation of success on the list of users
    And this user has the admin role
    And all their previous access rights remain intact

  @personas
  Scenario: Remove admin rights from a user, as administrator
    Given I am Gino
    And I am editing a user who has the admin role and access to inventory pools
    When I remove the admin role from this user
    And I save
    Then this user no longer has the admin role
    And all their previous access rights remain intact

  @personas
  Scenario Outline: As lending or inventory manager I can't access the admin area
    Given I am <person>
    When I try to access the admin area's user editing page
    Then I can't access that page
    When I try to access the admin area's user creation page
    Then I can't access that page
    Examples:
      | person |
      | Pius   |
      | Mike   |

  @javascript @personas
  Scenario: Add new user as inventory manager to an inventory pool
    Given I am Pius
    When I am looking at the user list
    And I add a user
    And I enter the following information
      | First name       |
      | Last name        |
      | E-Mail         |
    And I enter the login data
    And I enter a badge ID
    And I can only choose the following roles
      | No access |
      | Customer  |
      | Group manager  |
      | Lending manager  |
    When I choose the following roles
      | tab                | role              |
      | Customer              | customer          |
      | Group manager | group_manager   |
      | Lending manager | lending_manager   |
    And I assign multiple groups
    And I save
    Then the user and all their information is saved

  @personas
  Scenario: Add a new user as an administrator, from outside the inventory pool
    Given I am Gino
    And I am looking at the user list outside an inventory pool
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
  Scenario: Auflistung der Inventarpools eines Benutzers
    Given I am Ramon
    And I am looking at the user list outside an inventory pool
    And I edit a user that has access rights
    Then inventory pools they have access to are listed with the respective role

  @javascript @personas @browser
  Scenario: Requirements for deleting a user in an inventory pool
    Given I am Ramon
    And I pick one user with access rights, one with orders and one with contracts
    And I am looking at the user list in any inventory pool
    When I delete that user from the list
    Then I see an error message
    And the user is not deleted

  @personas
  Scenario: Alphabetic sort order of users outside an inventory pool
    Given I am Gino
    And I am looking at the user list outside an inventory pool
    # What's here? We need to confirm that A comes before B in the list

  @personas
  Scenario: Remove access as an inventory manager
    Given I am Pius
    And I am editing a user who has access to and no items from the current inventory pool
    When I remove their access
    And I save
    Then the user has no access to the inventory pool

  @javascript @personas
  Scenario: Delete user from an inventory pool as admin
    Given I am Gino
    And I pick a user without access rights, orders or contracts
    And I am looking at the user list in any inventory pool
    When I delete that user from the list
    Then that user has been deleted from the list
    And that user is deleted

  @personas
  Scenario: Remove access as an administrator
    Given I am Gino
    And I am editing a user who has access to and no items from an inventory pool
    When I remove their access
    And I save
    Then the user has no access to the inventory pool

  # This feature has been removed, no point in translating
  #@personas
  #Scenario: Startseite setzen
  #  Given I am Pius
  #  And man befindet sich auf der Liste der Benutzer
  #  When man die Startseite setzt
  #  Then ist die Liste der Benutzer die Startseite

  @javascript @personas @browser
  Scenario: Elements of user administration
    Given I am inventory manager or lending manager
    Then I can find the user administration features in the "Admin" area under "Users"
    Then I see a list of all users
    And I can filter to see only suspended users
    And I can filter by the following roles:
      | tab                | role               |
      | Customer              | customers          |
      | Lending manager | lending_managers   |
      | Inventory manager | inventory_managers |
    And I can open the edit view for each user

  @javascript @personas @browser
  Scenario: Displaying a user and their roles in lists
    Given I am inventory manager or lending manager
    And a user with assigned role appears in the user list
    Then I see the following information about the user, in order:
      |attr |
      |First name/last name|
      |Phone number|
      |Role|

  @javascript @personas @browser
  Scenario: Not displaying a user's role in lists if that user doesn't have a role
    Given I am inventory manager or lending manager
    And a user without assigned role appears in the user list
    Then I see the following information about the user, in order:
      |attr |
      |First name/last name|
      |Phone number|
      |Role|

  @javascript @personas @browser
  Scenario: Displaying a user in a list with their assigned roles and suspension status
    Given I am inventory manager or lending manager
    And a suspended user with assigned role appears in the user list
    Then I see the following information, in order:
      |attr |
      |First name/last name|
      |Phone number|
      |Role|
      |Suspended until dd.mm.yyyy|

  # English: lending manager
  @personas
  Scenario: Role 'lending manager'
    Given I am a lending manager
    When I open the inventory
    Then I can create new items
    And these items cannot be inventory relevant
    And I can create options
    And I can create and suspend users
    And I can retire items if my inventory pool is their owner and they are not inventory relevant

  # English: inventory manager
  @personas
  Scenario: Role 'inventory manager'
    Given I am an inventory manager
    Then I can create new models
    And I can create new items
    And these items can be inventory relevant
    And I can make another inventory pool the owner of the items
    And I can retire these items if my inventory pool is their owner
    And I can unretire items if my inventory pool is their owner
    And I can specify workdays and holidays for my inventory pool
    And I can assign and remove roles to and from users as specified in the following table, but only in the inventory pool for which I am manager
    | role                |
    | No access        |
    | Customer               |
    | Group manager   |
    | Lending manager  |
    | Inventory manager  |
    And I can do everything a lending manager can do
    When I don't choose a responsible department when creating or editing items
    Then the responsible department is the same as the owner

  @personas
  Scenario: Remove access as inventory manager
    Given I am Mike
    And I am editing a user who has access to and no items from the current inventory pool
    When I remove their access
    And I save
    Then the user has no access to the inventory pool

  @personas
  Scenario Outline: Remove access for a user with open contracts
    Given I am <persona>
    And there exists a contract with status "<contract_status>" for a user without any other contracts
    When I edit the user of this contract
    Then this user has access to the current inventory pool
    When I remove their access
    And I save
    Then I see the error message "<error_message>"
    Examples:
      | persona | contract_status | error_message                  |
      | Mike    | submitted       | Currently has open orders      |
      | Pius    | submitted       | Currently has open orders      |
      | Mike    | approved        | Currently has open orders      |
      | Pius    | approved        | Currently has open orders      |
      | Mike    | signed          | Currently has items to return |
      | Pius    | signed          | Currently has items to return |

  @upcoming
  Scenario: Editing the groups of a user
    Given I am Pius
    And I edit a user
    Then I can add groups using a list with autocomplete
    And I can remove groups
    And I save the user
    Then their group membership is saved

  @javascript @personas
  Scenario: As an inventory manager, add a new user to the inventory pool
    Given I am Mike
    When I am looking at the user list
    And I add a user
    And I enter the following information
      | Last name    |
      | First name   |
      | Address      |
      | Zip          |
      | City         |
      | Country      |
      | Phone        |
      | E-Mail       |
    And I enter the login data
    And I enter a badge ID
    And I can only choose the following roles
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    And I choose the following roles
    | tab               | role                |
    | Customer          | customer            |
    | Group manager     | group_manager       |
    | Lending manager   | lending_manager     |
    | Inventory manager | inventory_manager   |
    And I assign multiple groups
    And I save
    Then the user and all their information is saved

  @personas
  Scenario: Access rights available when editing a user as a lending manager
    Given I am Pius
    And I edit a user who has access as customer
    Then I can only choose the following roles
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
    When I change the access level to "lending manager"
    And I save
    Then the user has the role "lending manager"

  @personas
  Scenario: Switching a user to "customer"
    Given I am Pius
    And I edit a user who has access as lending manager
    When I change the access level to "customer"
    And I save
    Then the user has the role "customer"

  @personas
  Scenario: Access rights available when editing a user as an inventory manager
    Given I am Mike
    And I edit a user who has access as customer
    Then I can only choose the following roles
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    When I change the access level to "inventory manager"
    And I save
    Then the user has the role "inventory manager"

  @personas
  Scenario: Grant access to an inventory pool as an inventory manager
    Given I am Mike
    And I edit a user who doesn't have access to the current inventory pool
    When I change the access level to "customer"
    And I save
    Then I see a confirmation of success on the list of users
    And the user has the role "customer"

  @personas
  Scenario: Change access as an administrator
    Given I am Gino
    And I edit a user who is customer in any inventory pool
    Then I can only choose the following roles
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    When I change the access level to "inventory manager"
    And I save
    Then the user has the role "inventory manager"

  @javascript @personas @browser
  Scenario: Requirements for deleting a user
    Given I am Ramon
    And I am looking at the user list outside an inventory pool
    And I pick one user with access rights, one with orders and one with contracts
    When I delete that user from the list
    Then I see an error message
    And the user is not deleted

  @javascript @personas
  Scenario: Alphabetical sorting of users within an inventory pool
    Given I am Gino
    And I am looking at the user list in any inventory pool
    Then users are sorted alphabetically by first name

  @personas
  Scenario: Editing a user who has no access rights without granting them any
    Given I am Pius
    And I edit a user who doesn't have access to the current inventory pool
    When I change the email address
    And I save
    Then I see a confirmation of success on the list of users
    And the user's new email address is saved
    And the user still has access to the current inventory pool

  @javascript @personas
  Scenario: Add new user to the inventory pool as administrator
    Given I am Gino
    When I am looking at the user list in any inventory pool
    And I add a user
    And I enter the following information
      | Last name      |
      | First name     |
      | E-Mail         |
    And I enter the login data
    And I enter a badge ID
    Then I can only choose the following roles
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    When I choose the following roles
      | tab                | role                |
      | Customer              | customer            |
      | Group manager  | group_manager       |
      | Lending manager| lending_manager     |
      | Inventory manager| inventory_manager   |
    And I assign multiple groups
    And I save
    Then the user and all their information is saved

  @personas
  Scenario Outline: Adding a new user without supplying require information
    Given I am Pius
    When I am looking at the user list
    And I add a user
    And all required fields are filled in
    When I did not enter <required_information>
    And I save
    Then I see an error message
    Examples:
      | required_information |
      | last name    |
      | first name     |
      | email address      |

  @personas
  Scenario: Reactivate a user's access to an inventory pool
    Given I am Mike
    And I edit a user who used to have access to the current inventory pool
    When I change the access level to "customer"
    And I save
    Then I see a confirmation of success on the list of users
    And the user has the role "customer"


  @javascript @personas
  Scenario: Deleting a user as an administrator
    Given I am Gino
    And I am looking at the user list outside an inventory pool
    And I pick a user without access rights, orders or contracts
    When I delete that user from the list
    Then that user has been deleted from the list
    And that user is deleted 

  # Unimplemented, so not translated.
  @personas @upcoming
  Scenario: Startseite zurücksetzen
    Given I am Pius
    And man hat eine Startseite gesetzt
    When man seine Startseite zurücksetzt
    Then ist ist keine Startseite gesetzt
    When man auf das Logo klickt
    Then landet man auf der Tagesansicht als Standard-Startseite
