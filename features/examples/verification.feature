Feature: Verification

  Background:
    Given I am Andi

  @current @personas
  Scenario: Show inventory to group-manager
    When I open the "Inventory"
    Then I can view the timeline
    And I can export to a csv-file
    And i can search and filter
    But I can not edit models, items, options, software or licenses
    But I can not add models, items, options, software or licenses

  @current @personas
  Scenario: take-back in timeline not valid
    When I enter the timeline of a model with hand overs, take backs or pending orders
    And I click on a user's name
    Then there is no link to hand over
    And there is no link to take back
    And there is no link to acknowledge