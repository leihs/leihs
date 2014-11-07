Feature: Inventory Pool Settings

  In order to administer an inventory pool
  As a Inventory Manager
  I want to have functionalities to administrer my pool

  Background:
    Given I am Mike

  @upcoming
  Scenario: Define maximum amount of visits per week day
    When I edit my inventory pool settings
    Then I can enter the maximum visits per week day

  @upcoming
  Scenario: No maximum amount of visits defined
  	When I edit my inventory pool settings
    And I do not enter a maximum amount of visits on a week day
    Then there is no limit of visits for this week day

  @upcoming
  Scenario: Definition of maximum amount of visits per week day
    Given a maximum amount of visits is defined for a week day
    Then the amount includes potential hand overs (not yet acknowledged orders)
    And the amount includes hand overs
    And the amount includes take backs

  @upcoming
  Scenario: Define days between possible order submit and possible hand over
  	When I edit my inventory pool settings
    Then I can change the field "min. number of days between order and hand over"

