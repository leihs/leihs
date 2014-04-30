Feature: Sign Contract

  In order to modify an hand over
  As a lending manager
  I want to be able to delete a single line of an hand over (contract line)

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Delete a single line during the hand over
     When I open a hand over
      And I delete a line
     Then this line is deleted

  @javascript
  Scenario: Delete multiple lines during the hand over
     When I open a hand over which has multiple lines
      And I select multiple lines
      And I delete the seleted lines
     Then these lines are deleted

  @javascript
  Scenario: Delete lines which changes other lines availability
     When I open a hand over
      And I delete all lines of a model thats availability is blocked by these lines
     Then the availability of the keeped line is updated

  Scenario: Delete a hand over from the daily view
    Given I open the daily view
    When I delete a hand over
    Then all lines of that hand over are deleted
