Feature: Editing an item

  Background:
    Given I am Matti

  @javascript @personas
  Scenario: Order of the fields when editing an item
    Given I edit an item that belongs to the current inventory pool
    # TODO: Remove web_steps.rb
    When I select "Yes" from "item[retired]"
    When I choose "Investment"
    Then I see form fields in the following order:
      | field                      |
      | Inventory Code             |
      | Model                      |
      | - Status -                 |
      | Retirement                 |
      | Reason for Retirement      |
      | Working order              |
      | Completeness               |
      | Borrowable                 |
      | Status note                |
      | - Inventory -              |
      | Relevant for inventory     |
      | Supply Category            |
      | Owner                      |
      | Last Checked               |
      | Responsible department     |
      | Responsible person         |
      | User/Typical usage         |
      | - Move -                   |
      | Move                       |
      | Target area                |
      | - Toni Ankunftskontrolle - |
      | Check-In Date              |
      | Check-In State             |
      | Check-In Note              |
      | - General Information -    |
      | Serial Number              |
      | MAC-Address                |
      | IMEI-Number                |
      | Name                       |
      | Note                       |
      | - Location -               |
      | Building                   |
      | Room                       |
      | Shelf                      |
      | - Invoice Information -    |
      | Reference                  |
      | Project Number             |
      | Invoice Number             |
      | Invoice Date               |
      | Initial Price              |
      | Supplier                   |
      | Warranty expiration        |
      | Contract expiration        |

  @javascript @personas
  Scenario: Delete supplier
    Given I edit an item that belongs to the current inventory pool
    And I navigate to the edit page of an item that has a supplier
    When I delete the supplier
    And I save
    Then the item has no supplier

  @javascript @personas
  Scenario: Edit all an item's information
    Given I edit an item that belongs to the current inventory pool and is in stock and is not part of any contract
    When I enter the following item information
      | field                  | type         | value               |

      | Inventory Code         |              | Test Inventory Code |
      | Model                  | autocomplete | Sharp Beamer 456    |

      | Retirement             | select       | Yes                 |
      | Reason for Retirement  |              | Some reason         |
      | Working order          | radio        | OK                  |
      | Completeness           | radio        | OK                  |
      | Borrowable             | radio        | OK                  |

      | Relevant for inventory | select       | Yes                 |
      | Supply Category        | select       | Workshop Technology |
    And I save
    Then I am redirected to the inventory list
    And the item is saved with all the entered information

  @javascript @personas
  Scenario: Choosing a model without a version
    Given I edit an item that belongs to the current inventory pool
    And there is a model without a version
    When I assign this model to the item
    Then there is only product name in the input field of the model

  @javascript @personas
  Scenario: Change supplier
    Given I edit an item that belongs to the current inventory pool
    When I change the supplier
    And I save
    Then the edited item has the new supplier

  @javascript @personas
  Scenario: You can't change the responsible department for items that are not in stock
    Given I edit an item that belongs to the current inventory pool and is not in stock
    When I change the responsible department
    And I save
    Then I see an error message that I can't change the responsible inventory pool for items that are not in stock

  @javascript @personas
  Scenario: Editing an item an all its information
    Given I edit an item that belongs to the current inventory pool and is in stock and is not part of any contract
    When I enter the following item information
      | field                  | type         | value               |
      | Inventory Code         |              | Test Inventory Code |
      | Model                  | autocomplete | Sharp Beamer 456    |
      | Relevant for inventory | select       | Yes                 |
      | Supply Category        | select       | Workshop Technology |
      | Move                   | select       | sofort entsorgen    |
      | Target area            |              | Test room           |
      | Check-In Date          |              | 01/01/2013          |
      | Check-In State         | select       | transportschaden    |
      | Check-In Note          |              | Test note           |
      | Serial Number          |              | Test serial number  |
      | MAC-Address            |              | Test MAC address    |
      | IMEI-Number            |              | Test IMEI number    |
      | Name                   |              | Test name           |
      | Note                   |              | Test note           |
      | Building               | autocomplete | None                |
      | Room                   |              | Test room           |
      | Shelf                  |              | Test shelf          |
      | Reference              | radio must   | Investment          |
      | Project Number         |              | Test number         |
      | Invoice Number         |              | Test number         |
      | Invoice Date           |              | 01/01/2013          |
      | Initial Price          |              | 50.00               |
      | Warranty expiration    |              | 01/01/2013          |
      | Contract expiration    |              | 01/01/2013          |
      | Last Checked           |              | 01/01/2013          |
      | Responsible department | autocomplete | A-Ausleihe          |
      | Responsible person     |              | Matus Kmit          |
      | User/Typical usage     |              | Test use            |
    And I save
    Then I am redirected to the inventory list
    And the item is saved with all the entered information

  @javascript @personas
  Scenario: Required fields
    Given I edit an item that belongs to the current inventory pool
    Then "Reference" must be selected in the "Invoice Information" section
    When "Investment" is selected for "Reference", "Project Number" must also be supplied
    When "Yes" is selected for "Relevant for inventory", "Supply Category" must also be selected
    When "Yes" is selected for "Retirement", "Reason for Retirement" must also be supplied
    Then all required fields are marked with an asterisk
    And I cannot save the item if a required field is empty
    And I see an error message
    And the required fields are highlighted in red

  @javascript @personas
  Scenario: Create new supplier if it does not already exist
    Given I edit an item that belongs to the current inventory pool
    When I enter a supplier that does not exist
    And I save
    Then a new supplier is created
    And the edited item has the new supplier

  @javascript @personas
  Scenario: Do not create a new supplier if one of the same name already exists
    Given I edit an item that belongs to the current inventory pool
    When I enter a supplier
    And I save
    Then no new supplier is created
    And the edited item has the existing supplier

  @javascript @personas
  Scenario: Can't change the model for items that are in contracts
    Given I edit an item that belongs to the current inventory pool and is not in stock
    When I change the model
    And I save
    Then I see an error message that I can't change the model because the item is already handed over or assigned to a contract

  @javascript @personas
  Scenario: Can't retire an item that is not in stock
    Given I edit an item that belongs to the current inventory pool and is not in stock
    When I retire the item
    And I save
    Then I see an error message that I can't retire the item because it's already handed over or assigned to a contract
