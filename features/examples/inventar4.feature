# language: de

Funktionalität: Inventar

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Export der aktuellen Ansicht als CSV
    Dann kann man diese Daten als CSV-Datei exportieren
    Und die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden (inkl. Filter)

  @javascript
  Szenario: Keine Resultate auf der Liste des Inventars
    Wenn ich eine resultatlose Suche mache
    Dann sehe ich "Kein Eintrag gefunden"

  @javascript
  Szenario: Modell aufklappen
    Dann kann man jedes Modell aufklappen
    Und man sieht die Gegenstände, die zum Modell gehören
    Und so eine Zeile sieht aus wie eine Gegenstands-Zeile
