Feature: Add lines during hand over

  In order to hand things over and add lines to the contract
  As a lending manager
  I want to be able to have functionlities to add lines

  @javascript
  Scenario: Add an item to the hand over providing an inventory code
    Given I am "Pius"
     When I open a hand over
      And I add an item to the hand over by providing an inventory code and a date range
     Then the item is added to the hand over for the provided date range and the inventory code is already assigend
     
  @javascript
  Scenario: Add an option to the hand over providing an inventory code
    Given I am "Pius"
     When I open a hand over
      And I add an option to the hand over by providing an inventory code and a date range
     Then the option is added to the hand over for the provided date range
     
  @javascript
  Scenario: Increase the quantity of an option of the hand over by adding an option providing an inventory code
    Given I am "Pius"
     When I open a hand over
      And I add an option to the hand over which is already existing in the selected date range by providing an inventory code
     Then the existing option quantity is increased

  @javascript
  Scenario: Add an option to the hand over picking an autocomplete element
    Given I am "Pius"
     When I open a hand over
      And I type the beginning of an option to the add/assign input field
     Then I see a list of suggested option names
     When I select an option from the list
     Then this option is added to the hand over for the setted date range
     
  @javascript
  Scenario: Add an model to the hand over picking an autocomplete element
    Given I am "Pius"
     When I open a hand over
      And I type the beginning of a modelname to the add/assign input field
     Then I see a list of suggested model names
     When I select a modle from the list
     Then this model is added to the hand over for the setted date range but there is no inventory code assigned

  @javascript
  Scenario: Add an template (modelgroup) to the hand over picking an autocomplete element
    Given I am "Pius"
     When I open a hand over
      And I type the beginning of a template's name to the add/assign input field
     Then I see a list of suggested templates
     When I select a template from the list
     Then each model of the template is added to the hand over for the provided date range
     
  @javascript
  Scenario: Add lines which changes other lines availability
    Given I am "Pius"
     When I open a hand over
      And I add a model which is already part of this hand over for the same time range
     Then the availability of the already existing line is updated
     
  