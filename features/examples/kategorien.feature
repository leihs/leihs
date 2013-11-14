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

  @javascript
  Szenario: Kategorie löschen löscht auch alle Duplikate im Baum
    Wenn ich eine ungenutzte Kategorie lösche die im Baum mehrmals vorhanden ist
    Dann ist die Kategorie gelöscht und alle Duplikate sind aus dem Baum entfernt

  @javascript
  Szenario: Kategorien nicht löschbar wenn genutzt
    Wenn eine Kategorie genutzt ist
    Dann ist es nicht möglich die Kategorie zu löschen

  @javascript
  Szenario: Modell der Kategorie zuteilen
    Wenn man das Modell editiert
    Und ich die Kategorien zuteile
    Und ich das Modell speichere
    Dann sind die Kategorien zugeteilt

  @javascript
  Szenario: Kategorien entfernen
    Wenn man das Modell editiert
    Und ich eine oder mehrere Kategorien entferne
    Und ich das Modell speichere
    Dann sind die Kategorien entfernt und das Modell gespeichert

  @javascript
  Szenario: Kategorie suchen
    Wenn man nach einer Kategorie anhand des Namens sucht
    Dann sieht man nur die Kategorien, die den Suchbegriff im Namen enthalten
    Und sieht die Ergebnisse in alphabetischer Reihenfolge
    Und man kann diese Kategorien editieren

  @javascript
  Szenario: nicht genutzte Kategorie suchen und löschen 
    Wenn man nach einer ungenutzten Kategorie anhand des Namens sucht
    Dann sieht man nur die Kategorien, die den Suchbegriff im Namen enthalten
    Und man kann diese Kategorien löschen
