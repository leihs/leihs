Feature: Add Item during acknowledge process

  In order to add more items to a contract
  As a Lending Manager
  I want to have quick adding functionalities as well as adding a model by browsing trough all possible models

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Adding a model quickly to a contract by just typing in the inventory_number
    Given I open a contract for acknowledgement
    When I add a model by typing in the inventory code of an item of that model to the quick add
    Then the model is added to the contract

  @javascript @personas @browser
  Scenario: Autocompletion of the quick add input by model name
    Given I open a contract for acknowledgement
    When I start to type the name of a model which is not yet in the contract
    And I wait until the autocompletion is loaded
    Then I already see possible matches of models
    And only models related to my current pool are suggested
    When I select one of the matched models
    Then the model is added to the contract

  @javascript @personas
  Scenario: Increase the quantity of a contract line by adding an model from the same type and date range to the contract
    Given I open a contract for acknowledgement, whose start date is not in the past
    When I add a model to the acknowledge which is already existing in the selected date range by providing an inventory code
    Then the existing line quantity is not increased
    And an additional line has been created in the backend system
    And the new line is getting visually merged with the existing line

  @javascript @personas @browser
  Scenario: Search results should conform to the actual start and end date
    Given I open a contract for acknowledgement
    And I search for a model with default dates and note the current availability
    When I change the start date
    And I change the end date
    And I search again for the same model
    And I wait until the autocompletion is loaded
    Then the model's availability has changed

  @javascript @personas @browser
  Scenario: Show autocomplete also on frenzied interaction
    Given I open a contract for acknowledgement
    When I start searching some model for adding it
    And I leave the autocomplete
    And I reenter the autocomplete
    Then I should still see the model in the resultlist
