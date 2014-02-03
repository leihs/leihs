# language: de

Funktionalität: Kategorien

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Kategorien
    Dann man sieht das Register Kategorien

  @javascript
  Szenario: Kategorien erstellen
    Wenn man das Register Kategorien wählt
    Und man eine neue Kategorie erstellt
    Und man gibt man den Namen der Kategorie ein
    Und man gibt die Elternelemente und die dazugehörigen Bezeichnungen ein
    Und ich speichere
    Dann ist die Kategorie mit dem angegegebenen Namen und den zugewiesenen Elternelementen erstellt
