
Feature: Copy item

  Background:
    Given I am Mike

  @javascript @personas
  Scenario: Create and copy items
    Given I create an item
    And I choose "Investment"
    And I make a note of the original inventory code
    And I enter the following item information
      | field                  | type         | value               |
      | Borrowable             | radio        | OK                  |
      | Building               | autocomplete | None                |
      | Check-In Date          |              | 01/01/2013          |
      | Check-In Note          |              | Test note           |
      | Check-In State         | select       | transportschaden    |
      | Completeness           | radio        | OK                  |
      | Contract expiration    |              | 01/01/2013          |
      | IMEI-Number            |              | Test IMEI number    |
      | Initial Price          |              | 50.00               |
      | Invoice Date           |              | 01/01/2013          |
      | Invoice Number         |              | Test number         |
      | Last Checked           |              | 01/01/2013          |
      | MAC-Address            |              | Test MAC address    |
      | Model                  | autocomplete | Sharp Beamer 456    |
      | Move                   | select       | sofort entsorgen    |
      | Name                   |              | Test name           |
      | Note                   |              | Test note           |
      | Project Number         |              | Test number         |
      | Relevant for inventory | select       | Yes                 |
      | Responsible department | autocomplete | A-Ausleihe          |
      | Responsible person     |              | Matus Kmit          |
      | Retirement             | checkbox     | unchecked           |
      | Room                   |              | Test room           |
      | Serial Number          |              | Test serial number  |
      | Shelf                  |              | Test shelf          |
      | Supply Category        | select       | Workshop Technology |
      | Target area            |              | Test room           |
      | User/Typical usage     |              | Test use            |
      | Warranty expiration    |              | 01/01/2013          |
      | Working order          | radio        | OK                  |
    When I save and copy
    Then the item is saved
    And I can create a new item
    # This is not the case in the system
    #And the page title is 'Create copied item'
    And I can cancel
    And all fields except the following were copied:
    | Inventory Code |
    | Name           |
    | Serial Number  |
    And the inventory code is already filled in
    When I save
    Then the copied item is saved
    And I am redirected to the inventory list

  @javascript @personas
  Scenario: Copying an item selected from a list
    Given I open the inventory
    When I copy an item
    Then an item copy screen is shown
    And all fields except inventory code, serial number and name are copied

  @javascript @personas
  Scenario: Copying an item from the edit view
    When I am editing an item
    And I save and copy
    Then an item copy screen is shown
    And all fields except inventory code, serial number and name are copied

  @javascript @personas
  Scenario: Copying an item from another inventory pool
    Given I go to logout
    And I am Matti
    And I edit an item belonging to a different inventory pool
    And I save and copy
    Then an item copy screen is shown
    And all fields are editable, because the current inventory pool owns this new item

  @javascript @browser @personas
  Scenario: Creating a new supplier while copying an item
    Given I copy an item
    Then an item copy screen is shown
    When I enter a supplier that does not exist
    And I make a note of the inventory code for further steps
    And I save
    Then a new supplier is created
    And the copied item has the new supplier
