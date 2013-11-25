# language: de

Funktionalität: Kategorien

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

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

