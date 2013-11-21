Feature: Add lines during hand over

  In order to hand things over and add lines to the contract
  As a lending manager
  I want to be able to have functionlities to add lines

  Background:
    Given personas existing
      And I am "Pius"
     When I open a hand over

  @javascript
  Scenario: Add an option to the hand over picking an autocomplete element
      And I type the beginning of an option name to the add/assign input field
     Then I see a list of suggested option names
     When I select the option from the list
     Then the option is added to the hand over
     
  @javascript
  Scenario: Add an model to the hand over picking an autocomplete element
      And I type the beginning of a model name to the add/assign input field
     Then I see a list of suggested model names
     When I select the modle from the list
     Then the model is added to the hand over
