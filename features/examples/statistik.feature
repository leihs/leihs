
Feature: Statistics on lending and inventory

  Background:
    Given I am Ramon

  @personas
  Scenario: Where the statistics are visible
    When I am in the manage section
    Then I can choose to switch to the statistics section

  # AYAYAY! All the scenarios below are undefined
  @personas
  Scenario: Filtering statistics by time window
    Given ich befinde mich in der Statistik-Ansicht
    Then sehe ich normalerweise die Statistik der letzten 30 Tage
    When ich den Zeitraum eingrenze auf 1.1. - 31.12. des laufenden Jahres
    Then sehe ich nur statistische Daten die relevant sind für den 1.1. - 31.12. des laufenden Jahres
    When es sich beim Angezeigten um eine Ausleihe handelt
    Then sehe ich sie nur, wenn ihr Startdatum und ihr Rückgabedatum innerhalb der ausgewählten Zeit liegen

  @personas
  Scenario: Statistik über die Anzahl der Ausleihvorgänge pro Modell
    Given ich befinde mich in der Statistik-Ansicht über Ausleihvorgänge
    Then sehe ich dort alle Geräteparks, die Gegenstände besitzen
    When ich einen Gerätepark expandiere
    Then sehe ich alle Modelle, für die deren Gegenstände dieser Gerätepark verantwortlich ist
    And ich sehe für das Modell die Anzahl Ausleihen
    And ich sehe für das Modell die Anzahl Rücknahmen

  @personas
  Scenario: Statistik über Benutzer und deren Ausleihvorgänge
    Given ich befinde mich in der Statistik-Ansicht über Benutzer
    Then sehe ich für jeden Benutzer die Anzahl Aushändigungen
    Then sehe ich für jeden Benutzer die Anzahl Rücknahmen

  @personas
  Scenario: Expandieren eines Modells
    Given ich befinde mich in der Statistik-Ansicht
    When ich dort ein Modell sehe
    Then kann ich das Modell expandieren
    And sehe dann die Gegenstände, die zu diesem Modell gehören

  @personas
  Scenario: Statistik über den Wert der Modelle und Gegenstände
    Given ich befinde mich in der Statistik-Ansicht über den Wert
    Then sehe ich dort alle Geräteparks, die Gegenstände besitzen
    When ich einen Gerätepark expandiere
    Then sehe ich alle Modelle, für die dieser Gerätepark Gegenstände besitzt
    And für jedes  Modell die Summe des Anschaffungswerts aller Gegenstände dieses Modells in diesem Gerätepark
    And für jedes  Modell die Anzahl aller Gegenstände dieses Modells in diesem Gerätepark
    When ich ein solches Modell expandiere
    Then sehe ich eine Liste aller Gegenstände dieses Modells
    Then sehe ich für jeden Gegenstand seinen Anschaffungswert
