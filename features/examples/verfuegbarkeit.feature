# language: de

Funktionalität: Verfügbarkeit


  @personas @personas
  Szenario: Zuweisung einer Bestellungs-Zeile für ein Nicht-Gruppenmitglied
    Angenommen der Kunde ist nicht in der Gruppe "CAST"
    Und es gibt ein Modell, welches folgende Partitionen hat:
      | gruppe    | anzahl |
      | CAST      | 3      |
      | Allgemein | 5      |
    Wenn dieser Kunde das Modell bestellen möchte
    Dann ist dieses Modell für den Kunden "5" Mal verfügbar
    Dann ist dieses Modell für den Kunden nicht "8" Mal verfügbar

  @personas @personas
  Szenario: Zuweisung einer Bestellungs-Zeile für ein Gruppenmitglied
    Angenommen der Kunde ist in der Gruppe "CAST"
    Und es gibt ein Modell, welches folgende Partitionen hat:
      | gruppe    | anzahl |
      | CAST      | 3      |
      | Allgemein | 5      |
    Wenn dieser Kunde das Modell bestellen möchte
    Dann ist dieses Modell für den Kunden "8" Mal verfügbar

  @personas @personas
  Szenario: Prioritäten der Gruppen bei der Zuweisung
    Wenn ein Modell in mehreren Gruppen verfügbar ist
    Dann wird zuletzt die Gruppe "Allgemein" belastet

  @javascript @browser @personas
  Szenario: Keine Verfügbarkeitsberechnung bei Optionen
    Angenommen ich bin Pius
    Wenn eine Rücknahme nur Optionen enthält
    Dann wird für diese Optionen keine Verfügbarkeit berechnet