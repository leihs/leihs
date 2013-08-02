Feature: Availability

  Model test

  Background:
    Given personas existing

  Scenario: All items are available if there are no running reservations
    Given pending cucumber for: All items are available if there are no running reservations

  Scenario: All lines are available
    Given pending cucumber for: All lines are available

  Scenario: The quantity of items for users and models
    Test is performed for all personas

    Given list of all available models
    And list of all users
    When the quantity of items of a user for a specific model is retrieved
    And the quantity of items of a model for a specific user is retrieved
    Then these quantities must be equal

  Scenario: Total borrowable items
    Given pending cucumber for: Total borrowable items

  Scenario: Scoped by inventory pool
    Given pending cucumber for: Scoped by inventory pool

  Scenario: The maximum quantity available for users
    Given pending cucumber for: The maximum quantity available for users
