# language: de

Funktionalität: Kategorien

  Grundlage:
    Angenommen ich bin Mike
    Und man öffnet die Liste des Inventars

  @personas
  Szenario: Top-Level-Kategorien erstellen
    Wenn man das Register Kategorien wählt
    Und man eine neue Kategorie erstellt
    Und man gibt man den Namen der Kategorie ein
    Und ich speichere
    Dann ist die Kategorie mit dem angegegebenen Namen erstellt

  @javascript @personas
  Szenario: Kategorien anzeigen
    Wenn man das Register Kategorien wählt
    Dann sieht man die Liste der Kategorien
    Und die Kategorien sind alphabetisch sortiert
    Und die erste Ebene steht zuoberst
    Und man kann die Unterkategorien anzeigen und verstecken

  @javascript @personas
  Szenario: Kategorien editieren
    Wenn man eine Kategorie editiert
    Und man den Namen und die Elternelemente anpasst
    Und ich speichere
    Dann werden die Werte gespeichert

  @javascript @personas
  Szenario: Kategorien löschen
    Wenn eine Kategorie nicht genutzt ist
    Und man die Kategorie löscht
    Dann ist die Kategorie gelöscht und alle Duplikate sind aus dem Baum entfernt
    Und man bleibt in der Liste der Kategorien

  @javascript @personas
  Szenario: Kategorie löschen löscht auch alle Duplikate im Baum
    Wenn ich eine ungenutzte Kategorie lösche die im Baum mehrmals vorhanden ist
    Dann ist die Kategorie gelöscht und alle Duplikate sind aus dem Baum entfernt

  @javascript @personas
  Szenario: Kategorien nicht löschbar wenn genutzt
    Wenn eine Kategorie genutzt ist
    Dann ist es nicht möglich die Kategorie zu löschen

  @javascript @firefox @personas
  Szenario: Modell der Kategorie zuteilen
    Wenn man das Modell editiert
    Und ich die Kategorien zuteile
    Und ich das Modell speichere
    Dann sind die Kategorien zugeteilt

  @javascript @firefox @personas
  Szenario: Kategorien entfernen
    Wenn man das Modell editiert
    Und ich eine oder mehrere Kategorien entferne
    Und ich das Modell speichere
    Dann sind die Kategorien entfernt und das Modell gespeichert

  @javascript @firefox @personas
  Szenario: Kategorie suchen
    Wenn man nach einer Kategorie anhand des Namens sucht
    Dann sieht man nur die Kategorien, die den Suchbegriff im Namen enthalten
    Und sieht die Ergebnisse in alphabetischer Reihenfolge
    Und man kann diese Kategorien editieren

  @javascript @firefox @personas
  Szenario: nicht genutzte Kategorie suchen und löschen 
    Wenn man nach einer ungenutzten Kategorie anhand des Namens sucht
    Dann sieht man nur die Kategorien, die den Suchbegriff im Namen enthalten
    Und man kann diese Kategorien löschen

  @personas
  Szenario: Kategorien
    Dann man sieht das Register Kategorien

  @javascript @personas
  Szenario: Kategorien erstellen
    Wenn man das Register Kategorien wählt
    Und man eine neue Kategorie erstellt
    Und man gibt man den Namen der Kategorie ein
    Und man gibt die Elternelemente und die dazugehörigen Bezeichnungen ein
    Und ich speichere
    Dann ist die Kategorie mit dem angegegebenen Namen und den zugewiesenen Elternelementen erstellt
