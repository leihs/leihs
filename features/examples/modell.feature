
Feature: Model

  Background:
    Given I am Mike
    And I open the inventory

  @javascript @personas @browser
  Scenario: Overview when adding a new model
    When I add a new Model
    Then I can enter the following information:
      | Details |
      | Images  |
      | Attachments |
      | Accessories |

  @javascript @browser @personas
  Scenario: Filling in model details
    When I add a new Model
    And I enter the following details
      | Field                         | Value                     |
      | Product                       | Test model                |
      | Manufacturer                  | Test manufacturer         |
      | Description                   | Test description          |
      | Technical Details             | Test technical details    |
      | Internal Description          | Test internal description |
      | Important notes for hand over | Test notes                |
    And I save
    Then the new model is created and can be found in the list of unused models

  @javascript @personas
  Scenario: Editing model accessories
    When I edit a model that exists, is in use and already has activated accessories
    Then I see all the accessories for this model
    And I see which accessories are active for my pool
    When I add accessories and, if necessary, fill in the quantity in the text field
    And I save
    Then accessories are added to the model

  @javascript @personas
  Scenario: Deleting model accessories
    When I edit a model that exists, is in use and already has accessories
    Then I can delete a single accessory if it is not active in any other pool

  @javascript @personas
  Scenario: Deactivating model accessories
    When I edit a model that exists, is in use and already has activated accessories
    Then I can deactivate an accessory for my pool

  @javascript @browser @personas
  Scenario: Remove compatible models
    When I open a model that already has compatible models
    And I remove a compatible model
    And I save
    Then the model is saved without the compatible model that I removed

  @javascript @browser @personas
  Scenario: Editing group capacities
    Given I edit a model that exists and has group capacities allocated to it
    When I remove existing allocations
    And I add new allocations
    And I save
    Then the changed allocations are saved

  @javascript @personas
  Scenario: Delete model
    Given there is a model with the following conditions:
      | not in any contract |
      | not in any order|
      | no items assigned|
    When I delete this model from the list
    Then the model was deleted from the list
    And the model is deleted

  @javascript @browser @personas
  Scenario: Add compatible models
    When I edit a model that exists and is in use
    And I use the autocomplete field to add a compatible model
    And I save
    Then a compatible model has been added to the model I am editing

  @javascript @browser @personas
  Scenario: Adding a compatible model twice in a row
    When I open a model that already has compatible models
    And I add an already existing compatible model using the autocomplete field
    Then the redundant model was not added
    When I save
    Then the redundant compatible model was not added to this one

  @javascript @personas
  Scenario: Delete model associations
    Given there is a model with the following conditions:
      | not in any contract       |
      | not in any order          |
      | no items assigned         |
      | has group capacities      |
      | has properties            |
      | has accessories           |
      | has images                |
      | has attachments           |
      | is assigned to categories |
      | has compatible models     |
    When I delete this model from the list
    Then the model is deleted
    And all associations have been deleted as well

  @javascript @personas @browser
  Scenario: Editing model details
    When I edit a model that exists and is in use
    And I edit the following details
      | Field                         | Value                       |
      | Product                       | Test Modell x               |
      | Manufacturer                  | Test Hersteller x           |
      | Description                   | Test Beschreibung x         |
      | Technical Details             | Test Technische Details x   |
      | Internal Description          | Test Interne Beschreibung x |
      | Important notes for hand over | Test Notizen x              |
    And I save
    Then the information is saved
    And the data has been updated

  @javascript @personas
  Scenario Outline: Create attachments
    Given I add or edit a <object>
    Then I add one or more attachments
    And I can also remove attachments again
    And I save
    Then the attachments are saved
  Examples:
    | object   |
    | model    |
    | software |

  @javascript @personas
  Scenario Outline: Preventing deletion of a model
    Given the model has an assigned <assignment>
    Then I cannot delete the model from the list
  Examples:
    | assignment |
    | contract   |
    | order      |
    | item       |


  @javascript @browser @personas
  Scenario: Create a model with only a name
    When I add a new Model
    And I save
    Then the model is not saved because it does not have a name
    And I see an error message
    When I enter the name of an existing model
    And I save
    Then the model is not saved because it does not have a unique name
    And I see an error message
    When I edit the following details
      | Field   | Value         |
      | Product | Test Modell y |
    And I save
    Then the new model is created and can be found in the list of unused models

  @javascript @personas
  Scenario: Images
    When I edit a model that exists and is in use
    And I add multiple images
    Then I can also remove those images
    When I save the model and its images
    Then the remaining images are saved for that model
    And the images are resized to their thumbnail size when I see them in lists
