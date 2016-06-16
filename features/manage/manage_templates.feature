
Feature: Managing templates

  Background:
    Given I am Mike

  @personas
  Scenario: Show list of all templates
    When I click on "Templates" in the inventory area
    Then I see a list of currently available templates for the current inventory pool
    And the templates are ordered alphabetically by their names

  @javascript @personas
  Scenario: Create template
    Given I am listing templates 
    When I click the button "New Template"
    Then I can create a new template
    When I enter the template's name
    And I add some models to the template
    Then each model shows the maximum number of available items
    And each model I've added has the minimum quantity 1
    When I enter a quantity for each model
    And I save
    And I see the notice "Template created successfully"
    Then I am listing templates
    And the new template and all the entered information are saved

  @javascript @personas
  Scenario: Check whether a model's maximum quantity is exhausted
    Given I am creating a new template
    And I enter the template's name
    And I add some models to the template
    When I enter a quantity for a model which exceeds its maximum number of borrowable items for this model
    And I save
    Then I am warned that this template cannot never be ordered due to available quantities being too low
    And the new template and all the entered information are saved
    And the template is marked as unaccomplishable in the list
    When I edit the same template
    And I use correct quantities
    And I save
    Then I see the notice "Template successfully saved"
    And the edited template and all the entered information are saved
    And the template is not marked as unaccomplishable in the list

  @javascript @personas
  Scenario: Delete template
    Given I am listing templates
    Then I can delete any template directly from this list
    And the template has been deleted from the database

  @javascript @personas
  Scenario: Change template
    Given I am listing templates
    And a template with at least two models exists
    When I click the button "Edit"
    Then I am editing an existing template
    When I change the name
    And I delete a model from the list
    And I add an additional model
    Then the minimum quantity for the newly added model is 1
    And I change the quantity for one of the models
    And I save
    Then I see the notice "Template successfully saved"
    And I am listing templates
    And the edited template and all the entered information are saved

  @javascript @personas
  Scenario: Required information when editing a template
    Given I am editing a template
    When the name is not filled in
    And the template has at least one model
    And I save
    Then I see an error message
    When I fill in the name
    And I have not added any models
    And I save
    Then I see an error message

  @javascript @personas
  Scenario: Required information when creating a template
    Given I am creating a template
    When the name is not filled in
    And the template has at least one model
    And I save
    Then I see an error message
    When I fill in the name
    And I have not added any models
    And I save
    Then I see an error message

