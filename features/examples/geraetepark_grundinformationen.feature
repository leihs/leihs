
Feature: Basic information for inventory pools

  As a person responsible for managing inventory pools
  I want to be able to change their settings and supply basic information
  So that each inventory pool has all the information and settings they
  need to work efficiently (e.g. opening hours, proper addresses, etc.)

  @javascript @personas
  Scenario: Make basic settings
    Given I am Mike
    When I navigate to the inventory pool manage section
    Then I enter the inventory pool's basic settings as follows:
    | Name |
    | Short Name |
    | E-Mail |
    | Description |
    | Default Contract Note|
    | Print Contracts |
    | Automatic access |
    And I make a note of which page I'm on
    And I save
    Then I see a confirmation that the information was saved
    And the settings are updated
    And I am still on the same page

  @personas
  Scenario: Pflichtfelder der Grundinformationen zusammen prüfen
    Given I am Mike
    When I edit the current inventory pool
    And I leave the following fields empty:
      | Name       |
      | Short Name |
      | E-Mail     |
    And I save
    Then I see an error message

  @personas
  Scenario: Automatically grant access to new users from within my own inventory pool's settings
    Given I am Mike
    And multiple inventory pools are granting automatic access
    And my inventory pool is granting automatic access
    When I create a new user with the 'inventory manager' role in my inventory pool
    Then the newly created user has 'customer'-level access to all inventory pools that grant automatic access, but not to mine
    And in my inventory pool the user gets the role 'inventory manager'

  #72676850
  @personas @javascript @browser
  Scenario: Remove automatic access
    Given I am Mike
    And multiple inventory pools are granting automatic access
    And I edit an inventory pool that is granting automatic access
    When I disable automatic access
    And I save
    Then automatic access is disabled
    Given I am Gino
    And I am listing users
    When I have created a user with login "username" and password "password"
    Then the newly created user does not have access to that inventory pool

  @personas
  Scenario: Enable automatic access to a new inventory pool
    Given I am Mike
    And I edit an inventory pool that is not granting automatic access
    And there are users without access right to this inventory pool
    When I enable automatic access
    And I save
    Then automatic access is enabled
    And there are no users without access right to this inventory pool

  #72676850
  @personas
  Scenario Outline: Deselect checkboxes
    Given I am Mike
    And I edit an inventory pool
    When I enable "<checkbox>"
    And I save
    Then "<checkbox>" is enabled
    When I disable "<checkbox>"
    And I save
    Then "<checkbox>" is disabled
    Examples:
      | checkbox                |
      | Print contracts        |
      | Automatic suspension   |
      | Automatic access   |

  @personas
  Scenario: Manage workdays
   Given I am Mike
   And I edit my inventory pool settings
   When I randomly set the workdays monday, tuesday, wednesday, thursday, friday, saturday and sunday to open or closed
   And I save
   Then those randomly chosen workdays are saved

  @javascript @personas
  Scenario: Manage holidays
   Given I am Mike
   And I edit my inventory pool settings
   When I set one or more time spans as holidays and give them names
   And I save
   Then the holidays are saved
   And I can delete the holidays

  @personas
  Scenario Outline: Validate each field in inventory pool settings separately
    Given I am Mike
    When I edit the current inventory pool
    And I fill in the following fields in the inventory pool settings:
    | Name       |
    | Short Name |
    | E-Mail     |
    When I leave the field "<field>" in the inventory pool settings empty
    And I save
    Then I see an error message
    And the other fields still contain their data
    Examples:
      | field      |
      | Name       |
      | Short Name |
      | E-Mail     |

  @personas
  Scenario: Automatically suspend users with late contracts
    Given I am Mike
    When I edit the current inventory pool
    When I enable "Automatic suspension"
    Then I have to supply a reason for suspension
    When I save
    Then this configuration is saved
    When a user is suspended automatically due to late contracts
    Then they are suspended for this inventory pool until '1/1/2099'
    And the reason for suspension is the one specified for this inventory pool
    When I disable "Automatic suspension"
    And I save
    Then "Automatic suspension" is disabled

  @personas
  Scenario: Suspend users automatically only if they aren't already suspended
    Given I am Mike
    When on the inventory pool I enable the automatic suspension for users with overdue take backs
    And a user is already suspended for this inventory pool
    Then the existing suspension motivation and the suspended time for this user are not overwritten

