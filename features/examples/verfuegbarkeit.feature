
Feature: Availability

  # Ayayay, most of this is undefined!

  @personas
  Scenario: Assigning an order line to a non-group-member
    Given der Kunde ist nicht in der Gruppe "CAST"
    And es gibt ein Modell, welches folgende Partitionen hat:
      | gruppe    | anzahl |
      | CAST      | 3      |
      | Allgemein | 5      |
    When dieser Kunde das Modell bestellen möchte
    Then ist dieses Modell für den Kunden "5" Mal verfügbar
    Then ist dieses Modell für den Kunden nicht "8" Mal verfügbar

  @personas
  Scenario: Zuweisung einer Bestellungs-Zeile für ein Gruppenmitglied
    Given der Kunde ist in der Gruppe "CAST"
    And es gibt ein Modell, welches folgende Partitionen hat:
      | gruppe    | anzahl |
      | CAST      | 3      |
      | Allgemein | 5      |
    When dieser Kunde das Modell bestellen möchte
    Then ist dieses Modell für den Kunden "8" Mal verfügbar

  @personas
  Scenario: Prioritäten der Gruppen bei der Zuweisung
    When ein Modell in mehreren Gruppen verfügbar ist
    Then wird zuletzt die Gruppe "Allgemein" belastet

  @javascript @browser @personas
  Scenario: No availability for options
    Given I am Pius
    When a take back contains only options
    Then no availability will be computed for these options
