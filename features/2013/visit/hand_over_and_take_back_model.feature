Feature: Hand overs and take backs

  Model test (class methods)

  Background:
    Given personas existing

  Scenario: Hand overs are related to unsigned contracts
    Given there are "hand over" visits
    Then the associated contract of each such visit must be "unsigned"
    And each of the lines of such contract must also be "unsigned"

  Scenario: Take backs are related to signed contracts
    Given there are "take back" visits
    Then the associated contract of each such visit must be "signed"
    And each of the lines of such contract must also be "signed"
