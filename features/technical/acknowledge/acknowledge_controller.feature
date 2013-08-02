Feature: Acknowledge controller

  Add a line to an order during acknowledge process

  Background:
    Given personas existing
    And test data setup for acknowledge controller test

  Scenario: Adds a line to the order by providing a inventory code
    Given I log in as 'pius' with password 'password'
    When one adds a line to an order by providing a inventory code
    Then the response from this action should be successful

  Scenario: An added line has the same purpose of the existing lines
    Given I log in as 'pius' with password 'password'
    And prerequisites for scenario test "An added line has the same purpose of the existing lines" fullfilled
    When one adds a line to an order by providing a inventory code
    Then the response from this action should be successful
    And the added line has the same purpose of the existing lines
