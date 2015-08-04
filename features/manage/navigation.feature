
Feature: Navigation

  @personas
  Scenario: Navigation für Gruppen-Verwalter
    Given I am Andi
    And I visit the lending section
    Then seh ich die Navigation
    And die Navigation beinhaltet "Verleih"
    And die Navigation beinhaltet "Ausleihen"
    And die Navigation beinhaltet "Benutzer"

  @personas
  Scenario: Navigation für Gruppen-Verwalter in Verleih-Bereich
    Given I am Andi
    And I visit the lending section
    Then seh ich die Navigation
    And I open the tab "Orders"
    And I open the tab "Contracts"
    And man sieht die Gerätepark-Auswahl im Verwalten-Bereich

  @personas @javascript
  Scenario: Aufklappen der Geraeteparkauswahl und Wechsel des Geraeteparks
    Given I am Mike
    When I hover over the navigation toggler
    Then I see all inventory pools for which I am a manager
    When I click on one of the inventory pools
    Then I switch to that inventory pool
