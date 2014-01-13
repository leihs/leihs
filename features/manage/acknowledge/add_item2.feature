Feature: Add Item during acknowledge process

  In order to add more items to a contract
  As a Lending Manager
  I want to have quick adding functionalities as well as adding a model by browsing trough all possible models

  Background:
    Given personas existing
      And I am "Pius"
     When I open a contract for acknowledgement

  @javascript
  Scenario: Search results should conform to the actual start and end date
    Given I search for a model with default dates and note the current availability
    When I change the start date
    And I change the end date
    And I search again for the same model
    And I wait until the autocompletion is loaded
    Then the model's availability has changed

  @javascript
  Scenario: Show autocomplete also on frenzied interaction
    When I start searching some model for adding it
    And I leave the autocomplete
    And I reenter the autocomplete
    Then I should still see the model in the resultlist
