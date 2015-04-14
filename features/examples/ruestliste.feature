
Feature: Rüstliste

  Um die Gegenstände in den Gestellen möglichst schnell zu finden
  möchte ich als Verleiher
  dass mir das System eine Rüstliste mit Auflistung der jeweiligen Gestellen gibt

  Background:
    Given I am Pius

  @personas
  Scenario: Was ich auf der Rüstliste sehen möchte
    When I open a picking list
    Then möchte ich die folgenden Bereiche in der Rüstliste sehen:
    | Bereich          |
    | Datum            |
    | Titel            |
    | Ausleihender     |
    | Verleiher        |
    | Liste            |

  @personas @javascript @browser
  Scenario: Inhalt der Rüstliste vor Aushändigung - keine Zuteilung von Inventarcode
    Given es gibt eine Aushändigung mit mindestens einem nicht problematischen Modell und einer Option
    And I open the hand over
    And ich dem nicht problematischen Modell einen Inventarcode zuweise
    And wird der Gegenstand der Zeile zugeteilt
    And a line has no item assigned yet and this line is marked
    And an option line is marked
    When I open the picking list
    Then the lists are sorted by hand over date
    And each list contains following columns
    | Spaltenname                        |
    | Anzahl                             |
    | Inventarcode                       |
    | Modellname                         |
    | verfügbare Anzahl x Raum / Gestell |
    And each list will sorted after models, then sorted after room and shelf of the most available locations
    And in the list, the assigned items will displayed with inventory code, room and shelf
    And in the list, the not assigned items will displayed without inventory code
    And Gegenständen kein Raum oder Gestell zugeteilt sind, wird die verfügbare Anzahl für den Kunden und "x Ort nicht definiert" angezeigt
    And the missing location information for options, are displayed with "Location not defined"

  @personas @javascript @browser
  Scenario: Inhalt der Rüstliste vor Aushändigung - nicht verfügbare Gegenstände
    Given there is a hand over with at least one problematic line
    And I open the hand over
    And a line has no item assigned yet and this line is marked
    When I open the picking list
    Then the lists are sorted by hand over date
    And the not available items, are displayed with "Nicht verfügbar"

  @personas @javascript @browser
  Scenario: Inhalt der Rüstliste vor Aushändigung - nicht zugeteilt Raum und Gestell
    Given es gibt eine Aushändigung mit mindestens einem Gegenstand ohne zugeteilt Raum und Gestell
    And I open the hand over
    And a line with an assigned item which doesn't have a location is marked
    When I open the picking list
    Then Gegenständen kein Raum oder Gestell zugeteilt sind, wird "Ort nicht definiert" angezeigt

  @personas @javascript
  Scenario: Inhalt der Rüstliste nach Aushändigung - Inventarcodes sind bekannt
    When I open the picking list for a signed contract
    Then the lists are sorted by take back date
    And each list contains following columns
    | Spaltenname    |
    | Anzahl         |
    | Inventarcode   |
    | Modellname     |
    | Raum / Gestell |
    And each list will sorted after room and shelf
    When Gegenständen kein Raum oder Gestell zugeteilt sind, wird "Ort nicht definiert" angezeigt
    And the missing location information for options, are displayed with "Location not defined"

  @personas @javascript
  Scenario: Wo wird die Rüstliste aufgerufen
  	When I visit the lending section on the list of all contracts
    And I see at least a contract
    Then I can open the picking list of any contract line
    When I visit the lending section on the list of open contracts
    And I see at least a contract
    Then I can open the picking list of any contract line
    When I visit the lending section on the list of closed contracts
    And I see at least a contract
    Then I can open the picking list of any contract line
    When I open a hand over which has multiple lines
    And I select at least one line
    Then I can open the picking list
