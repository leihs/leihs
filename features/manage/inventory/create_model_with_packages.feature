
Feature: Create model with packages

  Background:
    Given I am Mike
    And I open the inventory

  @javascript @browser @personas
  Scenario: Create model with package assignments
    When I add a new Model
    And I fill in at least the required fields
    And I add one or more packages
    And I add one or more items to this package
    And I save both package and model
    Then the model is created and the packages and their assigned items are saved
    And the packages have their own inventory codes

  @javascript @browser @personas
  Scenario: A model that already has items cannot be turned into a package
    When I edit a model that already has items

    Then I cannot assign packages to that model

  @javascript @browser @personas
  Scenario: Can't create package without items
    When I add a package to a model
    Then I can only save this package if I also assign items

  @javascript @browser @personas @problematic
  Scenario: Remove single item from a package
    When I edit a package
    Then I can remove items from the package
    And those items are no longer assigned to the package

  @javascript @browser @personas
  Scenario: Entering package information for an existing model
    When I edit a model that already has packages
    And I edit an existing Package
    And I enter the following item information
    | field                  | type         | value           |
    | Working order          | radio        | OK              |
    | Completeness           | radio        | OK              |
    | Borrowable             | radio        | OK              |
    | Relevant for inventory | select       | Yes             |
    | Responsible department | autocomplete | A-Ausleihe      |
    | Responsible person     |              | Matus Kmit      |
    | User/Typical usage     |              | Test Verwendung |
    | Name                   |              | Test Name       |
    | Note                   |              | Test Notiz      |
    | Building               | autocomplete | None            |
    | Room                   |              | Test Raum       |
    | Shelf                  |              | Test Gestell    |
    | Initial Price          |              | 50.00           |
    | Last Checked           |              | 01/01/2013      |
    And I save both package and model
    Then the package has all the entered information

  @javascript @browser @personas
  Scenario: Creating a model with package assignment and then editing it
    When I add a new Model
    And I fill in at least the required fields
    And I add a package
    And I enter the package properties
    And I add one or more items to this package
    And I save this package
    And I edit an existing Package
    Then I enter the package properties
    And I add one or more items to this package

  #74210792
  @javascript @browser @personas @problematic
  Scenario: Entering package properties for newly created models
    When I add a package to a model
    And I add one or more items to this package
    And I enter the following item information
    | field                  | type         | value           |
    | Working order          | radio        | OK              |
    | Completeness           | radio        | OK              |
    | Borrowable             | radio        | OK              |
    | Relevant for inventory | select       | Yes             |
    | Responsible department | autocomplete | A-Ausleihe      |
    | Responsible person     |              | Matus Kmit      |
    | User/Typical usage     |              | Test Verwendung |
    | Name                   |              | Test Name       |
    | Note                   |              | Test Notiz      |
    | Building               | autocomplete | None            |
    | Room                   |              | Test Raum       |
    | Shelf                  |              | Test Gestell    |
    | Initial Price          |              | 50.00           |
    | Last Checked           |              | 01/01/2013      |
    And I save both package and model

    Then I see the notice "Model saved / Packages created"
    And the package has all the entered information
    And all the packaged items receive these same values store to this package
    | field                  |
    | Responsible department |
    | Responsible person     |
    | Building               |
    | Room                   |
    | Shelf                  |
    | Check-in Date          |
    | Last Checked           |


  @javascript @personas @browser @problematic
  Scenario: Delete an item package that was never handed over
    Given a never handed over item package is currently in stock
    When edit the related model package
    When I delete that item package
    Then the item package has been deleted
    And the packaged items are not part of that item package anymore
    When edit the related model package
    Then that item package is not listed

  @javascript @personas @problematic
  Scenario: Delete an item package related to a closed contract
    Given a once handed over item package is currently in stock
    When edit the related model package
    When I delete that item package
    Then the item package has been retired
    And the packaged items are not part of that item package anymore
    When edit the related model package
    Then that item package is not listed

  @personas
  Scenario: Can't delete a package if it's currently not in stock
    When the package is currently not in stock
    Then I can't delete the package

  @personas @javascript @browser
  Scenario: A model shows only packages owned by me
    When I edit a model that already has packages in mine and other inventory pools
    Then I only see packages which I am responsible for
