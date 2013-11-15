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
  Szenario: Top-Level-Kategorien erstellen
    Wenn man das Register Kategorien wählt
    Und man eine neue Kategorie erstellt
    Und man gibt man den Namen der Kategorie ein
    Und ich speichere
    Dann ist die Kategorie mit dem angegegebenen Namen erstellt

  @javascript
  Szenario: Kategorien erstellen
    Wenn man das Register Kategorien wählt
    Und man eine neue Kategorie erstellt
    Und man gibt man den Namen der Kategorie ein
    Und man gibt die Elternelemente und die dazugehörigen Bezeichnungen ein
    Und ich speichere
    Dann ist die Kategorie mit dem angegegebenen Namen und den zugewiesenen Elternelementen erstellt

  @javascript
  Szenario: Kategorien anzeigen
    Wenn man das Register Kategorien wählt
    Dann sieht man die Liste der Kategorien
    Und die Kategorien sind alphabetisch sortiert
    Und die erste Ebene steht zuoberst
    Und man kann die Unterkategorien anzeigen und verstecken

  @javascript
  Szenario: Kategorien editieren
    Wenn man eine Kategorie editiert
    Und man den Namen und die Elternelemente anpasst
    Und ich speichere
    Dann werden die Werte gespeichert

  @javascript
  Szenario: Kategorien löschen
    Wenn eine Kategorie nicht genutzt ist
    Und man die Kategorie löscht
    Dann ist die Kategorie gelöscht und alle Duplikate sind aus dem Baum entfernt
    Und man bleibt in der Liste der Kategorien
