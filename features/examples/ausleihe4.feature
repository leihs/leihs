# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Alle Suchresultate anzeigen
    Angenommen ich suche
    Dann erhalte ich Suchresultate in den Kategorien:
    | category     |
    | Benutzer     |
    | Modelle      |
    | Gegenstände  |
    | Verträge     |
    | Bestellungen |
    | Optionen     |
    Und ich sehe aus jeder Kategorie maximal die 3 ersten Resultate
    Wenn eine Kategorie mehr als 3 Resultate bringt
    Dann kann ich wählen, ob ich aus einer Kategorie mehr Resultate sehen will
    Wenn ich mehr Resultate wähle
    Dann sehe ich die ersten 5 Resultate
    Wenn die Kategorie mehr als 5 Resultate bringt
    Dann kann ich wählen, ob ich alle Resultate sehen will
    Wenn ich alle Resultate wähle erhalte ich eine separate Liste aller Resultate dieser Kategorie

  @javascript
  Szenario: Zusammenziehen der Anzahlen im Item-Popup
    Angenommen man fährt über die Anzahl von Gegenständen in einer Zeile
    Dann werden alle diese Gegenstände aufgelistet
    Und man sieht pro Modell eine Zeile
    Und man sieht auf jeder Zeile die Summe der Gegenstände des jeweiligen Modells