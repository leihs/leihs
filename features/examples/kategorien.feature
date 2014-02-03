# language: de

Funktionalität: Kategorien

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Top-Level-Kategorien erstellen
    Wenn man das Register Kategorien wählt
    Und man eine neue Kategorie erstellt
    Und man gibt man den Namen der Kategorie ein
    Und ich speichere
    Dann ist die Kategorie mit dem angegegebenen Namen erstellt

  @javascript
  Szenario: Kategorien anzeigen
    Wenn man das Register Kategorien wählt
    Dann sieht man die Liste der Kategorien
    Und die Kategorien sind alphabetisch sortiert
    Und die erste Ebene steht zuoberst
    Und man kann die Unterkategorien anzeigen und verstecken
