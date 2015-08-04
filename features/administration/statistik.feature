Feature: Statistics on lending and inventory

  Background:
    Given I am Ramon

  @personas
  Scenario: Where the statistics are visible
    When I am in the admin section
    Then I can choose to switch to the statistics section

  @personas
  Scenario: Title of the statistics section
    Given I am in the statistics section
    Then the page title is 'Statistics'

  @personas
  Scenario: Filtering statistics by time window
    Given I am in the statistics section
    And I select the statistics subsection "Who borrowed the most things?"
    Then I see by default the last 30 days' statistics
    When I set the time frame to 1/1 - 31/12 of the current year
    Then I see only statistical data concerning the time period of 1/1 - 31/12 of the current year
    When what I am looking at is a hand over
    Then I only see it if its start and end date are both inside the chosen time period

  @personas
  Scenario: Statistics on number of hand overs and take backs per model
    Given I am in the statistics section
    And I select the statistics subsection "Which inventory pool is busiest?"
    #Then I see all inventory pools that own items
    #When I expand an inventory pool
    #Then I see all models which this inventory pool is responsible for
    #And I see the number of hand overs for the model
    #And I see the number of take backs for the model

  @personas
  Scenario: Statistics about users and their lendings
    Given I am in the statistics section
    And I select the statistics subsection "Who borrowed the most things?"
    Then I see for each user the number of hand overs
    Then I see for each user the number of take backs

  @personas
  Scenario: Expanding a model
    Given I am in the statistics section
    When I see a model there
    Then I can expand that model
    And I see items belonging to that model

  @personas
  Scenario: Statistics about the items' value
    Given I am in the statistics section
    And I select the statistics subsection "Who bought the most items?"
    Then I see all inventory pools that own items
    When I expand an inventory pool
    Then I see all models for which this inventory pool owns items
    And for each model a sum of the purchase price of all matching items in this inventory pool
    And for each model the number of items of this model in that inventory pool
    When I expand that model
    Then I see a list of all items of this model
    And I see the purchase price of each item
