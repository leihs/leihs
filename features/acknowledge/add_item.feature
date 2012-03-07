Feature: Add Item during acknowledge process

  In order to add more items to an order
  As an Inventory Manager
  I want to have quick adding functionalities as well as adding a model by browsing trough all possible models

  Background: Load the personas
    Given personas are loaded
    
  @javascript
  Scenario: Adding a model quickly to an order by just typing in the serial_number or inventory_number
    When I am 'Pius'
     And I open the order from "Normin" for acknowledgment
     And I type ""
    


