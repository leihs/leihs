Feature: Inventory Pool Settings

  In order to administer an inventory pool
  As a Inventory Manager
  I want to have functionalities to administrer my pool

  Background:
    Given I am Mike

  @personas
  Scenario: Define maximum amount of visits per week day
    When I edit my inventory pool settings
    Then I can enter the maximum visits per week day

  @personas
  Scenario: No maximum amount of visits defined
    When I edit my inventory pool settings
    And I do not enter a maximum amount of visits on a week day
    Then there is no limit of visits for this week day

  @personas
  Scenario: Definition of maximum amount of visits per week day
    Given a maximum amount of visits is defined for a week day
    Then the amount of visits includes
      | potential hand overs (not yet acknowledged orders) |
      | hand overs                                         |
      | take backs                                         |

  @personas
  Scenario: Define days between possible order submit and possible hand over
    When I edit my inventory pool settings
    Then I can change the field "Min. number of days between order and hand over"
