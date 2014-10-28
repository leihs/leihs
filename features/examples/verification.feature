Feature: Verification

  Background:
    Given I am Andi
    When I open the Inventory

  @personas @javascript @browser
  Scenario: Show inventory to group-manager
    Then for each visible model I can see the Timeline
    And I can export to a csv-file
    And I can search and filter
    But I can not edit models, items, options, software or licenses
    And I can not add models, items, options, software or licenses

  @personas @javascript
  Scenario: take-back in timeline not valid
    When I enter the timeline of a model with hand overs, take backs or pending orders
    And I click on a user's name
    Then there is no link to:
      | acknowledge |
      | hand over   |
      | take back   |
