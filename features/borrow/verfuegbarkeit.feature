
Feature: Verfügbarkeit

  Background:
    Given I am Normin
    And I have an unsubmitted order with models
    And the contract timeout is set to 30 minutes

  @personas
  Scenario: Overbooking by lending managers
    When I add a model to an order
    Given I am Pius
    When I add the same model to an order
    And the maximum quantity of items is exhausted
    Given I am Normin
    When I open my list of orders
    And I submit the order
    Then the order is not submitted
    And I am redirected to my current order
    And I see an error message

  @personas
  Scenario: Blocking models
    When I perform some activity
    Then the models in my order remain blocked

  @personas
  Scenario: Releasing blocked models
    When I have performed no activity for more than 30 minutes
    Then the models in my order are released

  @personas
  Scenario: Reblocking after inactivity
    When I have performed no activity for more than 30 minutes
    And all models are available
    When I perform some activity
    Then I can continue my order process
    And the models in my order remain blocked

  @personas
  Scenario: Models become unavailable after long inactivity
    Given a model is not available
    When I have performed no activity for more than 30 minutes
    When I perform some activity
    Then I am redirected to the timeout page
