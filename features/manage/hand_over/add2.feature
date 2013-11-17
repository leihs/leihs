Feature: Add lines during hand over

  In order to hand things over and add lines to the contract
  As a lending manager
  I want to be able to have functionlities to add lines

  Background:
    Given personas existing
      And I am "Pius"
     When I open a hand over

  @javascript
  Scenario: Add a template to the hand over picking an autocomplete element
      And I type the beginning of a template name to the add/assign input field
     Then I see a list of suggested template names
     When I select the template from the list
     Then each model of the template is added to the hand over for the provided date range
     
  @javascript
  Scenario: Add lines which changes other lines availability
      And I add so many lines that I break the maximal quantity of an model
     Then I see that all lines of that model have availability problems