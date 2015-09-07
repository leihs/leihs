
Feature: Navigation

  @personas
  Scenario: Navigation für Gruppen-Verwalter
    Given I am Andi
    And I visit the lending section
    Then I can see the navigation bars
    And the navigation contains "Lending"
    And the navigation contains "Borrow"
    And the navigation contains "User"

  @personas
  Scenario: Navigation für Gruppen-Verwalter in Verleih-Bereich
    Given I am Andi
    And I visit the lending section
    Then I can see the navigation bars
    And I open the tab "Orders"
    And I open the tab "Contracts"

  @personas @javascript
  Scenario: Aufklappen der Geraeteparkauswahl und Wechsel des Geraeteparks
    Given I am Mike
    When I hover over the navigation toggler
    Then I see all inventory pools for which I am a manager
    When I click on one of the inventory pools
    Then I switch to that inventory pool
