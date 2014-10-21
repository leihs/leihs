

Feature: Verification

  @upcoming
  Scenario: Show inventory to group-manager
    Given I am Andi
    When I open the "Inventory"
    Then I can view the timeline
    And I can export to a csv-file
    And i can search and filter
    But I can not edit models, items, options, software or licenses
    But I can not add models, items, options, software or licenses

  @upcoming
  Scenario: take-back in timeline not valid
    Given I am Andi  
    When I enter the timeline of a model with hand overs, take backs or pending orders
    And I click on a user's name
    Then there is no link to hand over
    And there is no link to take back
    And there is no link to acknowledge