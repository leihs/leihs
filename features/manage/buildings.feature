Feature: Buildings

  Background:
    Given I am Gino
    When I visit "/manage/buildings"

  @personas
  Scenario: Listing existing buildings
    Then I see a list of buildings

  @personas
  Scenario: Creating existing buildings
    When I create a new building providing all required values
    And I save
    Then I see a list of buildings
    And I see the new building

  @personas
  Scenario: Creating existing buildings
    When I create a new building not providing all required values
    And I save
    Then I see an error message
    And I see the building form

  @personas
  Scenario: Editing existing buildings
    When I edit an existing building
    And I save
    Then I see a list of buildings
    And I see the edited building

  @personas @javascript
  Scenario: Deleting existing buildings
    Given there is a deletable building
    When I visit "/manage/buildings"
    When I delete a building
    Then I see a list of buildings
    And I don't see the deleted building
