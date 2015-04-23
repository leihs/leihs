Feature: Sign Contract

  In order to modify an hand over
  As a lending manager
  I want to be able to delete a single line of an hand over (contract line)

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Delete a single line during the hand over
    When I open a hand over
    And I delete a line
    Then this line is deleted

  @javascript @personas
  Scenario: Delete multiple reservations during the hand over
    When I open a hand over which has multiple reservations
    And I select multiple reservations
    And I delete the seleted reservations
    Then these seleted reservations are deleted

  @javascript @personas @browser
  Scenario: Delete reservations which changes other reservations availability
    When I open a hand over
    And I delete all reservations of a model thats availability is blocked by these reservations
    Then the availability of the keeped line is updated

  @javascript @personas
  Scenario: Delete a hand over from the daily view
    Given I navigate to the hand over visits
    When I delete a hand over
    Then all reservations of that hand over are deleted
