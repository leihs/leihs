Feature: Add lines during hand over

  In order to hand things over and add lines to the contract
  As a lending manager
  I want to be able to have functionlities to add lines

  Background:
    Given I am "Pius"
     When I open a hand over

  @javascript
  Scenario: Add an item to the hand over providing an inventory code
     When I add a borrowable item to the hand over by providing an inventory code
     Then the item is added to the hand over for the provided date range and the inventory code is already assigend
     When I add an unborrowable item to the hand over by providing an inventory code
     Then the item is added to the hand over for the provided date range and the inventory code is already assigend

  @javascript
  Scenario: Add an option to the hand over providing an inventory code
      And I add an option to the hand over by providing an inventory code and a date range
     Then the option is added to the hand over

  @javascript
  Scenario: Increase the quantity of an option of the hand over by adding an option providing an inventory code
      And I add an option to the hand over which is already existing in the selected date range by providing an inventory code
     Then the existing option quantity is increased

  @javascript @firefox
  Scenario: Add a template to the hand over picking an autocomplete element
      And I type the beginning of a template name to the add/assign input field
     Then I see a list of suggested template names
     When I select the template from the list
     Then each model of the template is added to the hand over for the provided date range

  @javascript @firefox
  Scenario: Add lines which changes other lines availability
      And I add so many lines that I break the maximal quantity of an model
     Then I see that all lines of that model have availability problems

  @javascript @firefox
  Scenario: Add an option to the hand over picking an autocomplete element
      And I type the beginning of an option name to the add/assign input field
     Then I see a list of suggested option names
     When I select the option from the list
     Then the option is added to the hand over

  @javascript @firefox
  Scenario: Add an model to the hand over picking an autocomplete element
      And I type the beginning of a model name to the add/assign input field
     Then I see a list of suggested model names
     When I select the modle from the list
     Then the model is added to the hand over

  @upcoming
  Scenario: hand over items even if not borrowable
     Given I open a hand over
     When I enter a model or a software
     Then I see a list of suggested model and software names
     And the models and software shown can be borrowable or not borrowable
     When all items of a specific model or software are set to "not borrowable"
     And I enter this specific model or software in the add/assign input field
     Then I see this specific model in the suggested model list


