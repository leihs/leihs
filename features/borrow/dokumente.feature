
Feature: User documents

  Background:
    Given I am a customer with contracts

  @javascript @personas
  Scenario: Getting to my documents
    When I click on "My Documents" underneath my username
    Then I am on the page showing my documents

  @javascript @personas
  Scenario: Document overview
    Given I am on my documents page
    Then my contracts are ordered by the earliest time window
    And I see the following information for each contract:
      | Contract number                    |
      | Time window with its start and end |
      | Inventory pool                     |
      | Purpose                            |
      | Status                             |
      | Link to the contract               |
      | Link to the value list             |

  @javascript @personas
  Scenario: Person taking back
    When I open a contract with returned items from my documents
    Then the relevant lines show the person taking back the item in the format "F. Lastname"

  @javascript @personas
  Scenario: Opening value list
    Given I am on my documents page
    And I click the value list link
    Then the value list opens

  @javascript @personas
  Scenario: What I want to see on a value list
    When I open a value list from my documents
    Then I see the value list displayed as in the manage section

  @javascript @personas
  Scenario: Opening a contract
    Given I am on my documents page
    And I click the contract link
    Then the contract opens

  @javascript @personas
  Scenario: What I want to see on the contract
    When I open a contract from my documents
    Then I see the contract and it looks like in the manage section
