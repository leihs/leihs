
Feature: Gegenstand erstellen

  @javascript @personas
  Scenario: Order of the fields when creating an item
    Given I am Matti
    And I create an item
    # WHY are we retiring the item? Is it necessary so we can see an edit view?
    # TODO: Explain the rationale.
    # TODO: Remove web_steps.rb
    And I select "Yes" from "item[retired]"
    And I choose "Investment" as reference
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
  Scenario: Forgetting to fill out the required fields when creating an item
    Given I am Matti
    And I create an item
    And I choose "Investment" as reference
    And these required fields are blank:
    | Model           |
    | Inventory Code  |
    | Project Number  |
    | Supply Category |
    Then the model cannot be created
    And I see an error message

  @javascript @personas
  Scenario Outline: Forgetting to fill out just one required field when creating an item
    Given I am Matti
    And I create an item
    And I choose "Investment" as reference
    And these required fields are filled in:
    | Model           |
    | Inventory Code  |
    | Project Number  |
    | Supply Category |
    When I leave the field "<required_field>" empty
    Then the model cannot be created
    And I see an error message
    And the other fields still contain their data
    Examples:
      | required_field  |
      | Model           |
      | Inventory Code  |
      | Project Number  |
      | Supply Category |

  @javascript @personas
  Scenario: Areas where you can create an item
    Given I am Matti
    And I open the inventory
    Then I can create an item

  @javascript @personas
  Scenario: Creating a new supplier if it does not already exist
    Given I am Mike
    And I create an item
    And I choose "Investment" as reference
    And these required fields are filled in:
    | Model        |
    | Inventory Code|
    | Project Number |
    | Supply Category |
    When I enter a supplier that does not exist
    And I save
    Then a new supplier is created
    And the created item has the new supplier

  @javascript @personas
  Scenario: Creating an item with all its information
    Given I am Matti
    And I create an item
    And I enter the following item information
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
  Scenario: Fields that are already filled in
    Given I am Matti
    And I create an item
    Then the barcode is already filled in
    And The date this item was last checked is today's date
    And the following fields have their default values
    | field                  | type   | value        |
    | Borrowable             | radio  | Unborrowable |
    | Relevant for inventory | select | Yes          |
    | Working order          | radio  | OK           |
    | Completeness           | radio  | OK           |
    | Supply Category        | select |              |

  @javascript @personas
  Scenario: Specifying values for supply category
    Given I am Matti
    And I create an item
    Then the field 'Supply Category' offers the following choices
    | Workshop Technology   |
    | Production Technology |
    | AV Technology         |
    | Musical Instrument    |
    | Facility Management   |
    | IT/Software           |
