Feature: Displaying availability 

  Background:
    Given I am Pius

  @javascript @browser @personas
  Scenario: Displaying availability when adding things to an order
    Given I edit an order
    And I search for a model to add
    Then the availability of the model is displayed as: "2(3)/7 Model name type"

  @javascript @browser @personas
  Scenario: Displaying availability when adding things to a hand over
    Given I am doing a hand over
    And I search for a model to add
    Then the availability of the model is displayed as: "2(3)/7 Model name type"
