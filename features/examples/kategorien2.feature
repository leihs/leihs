# language: de

Funktionalität: Kategorien

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

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
