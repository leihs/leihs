Feature: Add Item during acknowledge process

  In order to add more items to an order
  As an Inventory Manager
  I want to have quick adding functionalities as well as adding a model by browsing trough all possible models

  Background: Load the personas
    Given personas are loaded
    
  @javascript
  Scenario: Adding a model quickly to an order by just typing in the serial_number or inventory_number
   Given I am "Pius"
     And I edit an order for acknowledgment
    When I add an item through the quick add item field
    Then the item is added to the order 
    
  @javascript
  Scenario: Autocompletion of quick add input
  
  @javascript
  Scenario: Choose a model to add to the order by opening the add model dialog
     