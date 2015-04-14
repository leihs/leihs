
Feature: Inventory (CSV export)

  @personas
  Scenario: Export of the entire inventory to a CSV file
    Given I am Gino
    And I open the list of inventory pools
    Then I can export to a CSV file

  @javascript @personas @browser
  Scenario: Export der aktuellen Ansicht als CSV
    Given I am Mike
    And I open the inventory
    When I view the tab "Models"
    Then I can export this data as a CSV file
    And the file contains the same lines as are shown right now, including any filtering
    And the lines contain the following fields in order:
      | Fields                        |
      | Created at                    |
      | Updated at                    |
      | Product |
      | Version               |
      | Manufacturer                  |
      | Description                   |
      | Technical Details             |
      | Internal Description          |
      | Important notes for hand over |
      | Categories                    |
      | Accessories                   |
      | Compatibles                   |
      | Properties                    |
      | Inventory Code                |
      | Serial Number                 |
      | MAC-Address                   |
      | IMEI-Number                   |
      | Name                          |
      | Note                          |
      | Retirement                    |
      | Reason for Retirement         |
      | Working order                 |
      | Completeness                  |
      | Borrowable                    |
      | Status note                   |
      | Building                      |
      | Room                          |
      | Shelf                         |
      | Relevant for inventory        |
      | Owner                         |
      | Last Checked                  |
      | Responsible department        |
      | Responsible person            |
      | User/Typical usage            |
      | Supply Category               |
      | Reference                     |
      | Project Number                |
      | Invoice Number                |
      | Invoice Date                  |
      | Initial Price                 |
      | Supplier                      |
      | Warranty expiration           |
      | Contract expiration           |
      | Move                          |
      | Target area                   |
      | Check-In Date                 |
      | Check-In State                |
      | Check-In Note                 |
    When I view the tab "Software"
    Then I can export this data as a CSV file
    And the file contains the same lines as are shown right now, including any filtering
    And the lines contain the following fields in order:
      | Fields                 |
      | Created at             |
      | Updated at             |
      | Product                |
      | Version                |
      | Manufacturer           |
      | Software Information   |
      | Inventory Code         |
      | Serial Number          |
      | Note                   |
      | Activation Type        |
      | Dongle ID              |
      | License Type           |
      | Total quantity         |
      | Quantity allocations   |
      | Operating System       |
      | Installation           |
      | License expiration     |
      | Retirement             |
      | Reason for Retirement  |
      | Borrowable             |
      | Owner                  |
      | Responsible department |
      | Reference              |
      | Project Number         |
      | Invoice Date           |
      | Initial Price          |
      | Supplier               |
      | Procured by            |
      | Maintenance contract   |
      | Maintenance expiration |
      | Currency               |
      | Price                  |
