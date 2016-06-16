
Feature: Model overview

  Um ausführliche Informationen über ein Modell zu erhalten
  möchte ich als Ausleihender
  die Möglichkeit haben ausführliche Informationen über ein Modell zu sehen

  @personas
  Scenario: Model overview
    Given I am Normin
    And I am listing a category of models of which at least one is borrowable by me
    When I pick one model from the list
    Then I see that model's detail page
    And I see the following model information:
    | Model name        |
    | Manufacturer      |
    | Images            |
    | Description       |
    | Attachments       |
    | Properties        |
    | Compatible models |

  @javascript @personas
  Scenario: Zoom in on images
    Given I am Normin
    And I see a model's detail page that includes images of the model
    When I hover over such an image
    Then that image becomes the main image
    When I hover over another image
    Then that other image becomes the main image
    When I click on an image
    Then that image remains the main image even when I'm not hovering over it

  @javascript @personas
  Scenario: Showing properties
    Given I am Normin
    And I see a model's detail page that includes properties
    Then the first five properties are shown with their keys and values
    When I toggle all properties
    Then all properties are displayed
    And I can use the same toggle to collapse the properties again
