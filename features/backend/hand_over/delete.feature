Feature: Sign Contract

  In order to modify an hand over
  As a lending manager
  I want to be able to delete a single line of an hand over (contract line)

  @javascript
  Scenario: Delete a single line during the hand over
    Given I am "Pius"
     When I open a hand over
      And I delete a line
     Then this line is deleted

  @javascript
  Scenario: Delete lines which changes other lines availability
    Given I am "Pius"
     When I open a hand over
      And I delete a line with a model that exists twice in the same time range
     Then the availability of the keeped line is updated