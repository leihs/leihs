Feature: Add Item during acknowledge process

  In order to add more items to an order
  As a Lending Manager
  I want to have quick adding functionalities as well as adding a model by browsing trough all possible models

  Background:
    Given personas existing
      And I am "Pius"
     When I open an order for acknowledgement

  @javascript
  Scenario: Adding a model quickly to an order by just typing in the inventory_number
     When I add a model by typing in the inventory code of an item of that model to the quick add
     Then the model is added to the order

  @javascript
  Scenario: Autocompletion of the quick add input by inventory code
     When I start to type the inventory code of an item
      And I wait until the autocompletion is loaded
     Then I already see possible matches of models
     When I select one of the matched models
     Then the model is added to the order

  @javascript
  Scenario: Autocompletion of the quick add input by model name
     When I start to type the name of a model
      And I wait until the autocompletion is loaded
     Then I already see possible matches of models
     When I select one of the matched models
     Then the model is added to the order

  @javascript
  Scenario: Increase the quantity of an order line by adding an model from the same type and date range to the order
     When I add a model to the acknowledge which is already existing in the selected date range by providing an inventory code
     Then the existing line quantity is not increased
      And an additional line has been created in the backend system
      And the new line is getting visually merged with the existing line

  @javascript
  Scenario: Search results should conform to the actual start and end date
    Given I search for a model with default dates and note the current availability
    When I change the start date
    And I change the end date
    And I search again for the same model
    And I wait until the autocompletion is loaded
    Then the model's availability has changed
