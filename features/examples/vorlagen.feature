# language: de

Funktionalität: Vorlagen verwalten

  Als Ausleihe-Verwalter / Inventar-Verwalter möchte ich 
  die Möglichkeit haben, Vorlagen zu verwalten

  Grundlage:
    Angenommen man ist "Mike"

  Szenario: Liste aller Vorlagen anzeigen
    Wenn ich im Inventarbereich auf den Link "Vorlagen" klicke
    Dann öffnet sich die Seite mit der Liste der im aktuellen Inventarpool erfassten Vorlagen
    Und die Vorlagen für dieses Inventarpool sind alphabetisch nach Namen sortiert

  @javascript
  Szenario: Vorlage erstellen
    Und ich befinde mich auf der Liste der Vorlagen
    Wenn ich auf den Button "Neue Vorlage" klicke
    Dann öffnet sich die Seite zur Erstellung einer neuen Vorlage
    Wenn ich den Namen der Vorlage eingebe
    Und ich Modelle hinzufüge
    Dann steht bei jedem Modell die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell
    Und für jedes hinzugefügte Modell ist die Mindestanzahl 1
    Wenn ich zu jedem Modell die Anzahl angebe
    Und ich speichere
    Dann ich wurde auf die Liste der Vorlagen weitergeleitet
    Und ich sehe die Erfolgsbestätigung
    Und die neue Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert

  @javascript
  Szenario: Prüfen, ob max. Anzahl bei den Modellen überschritten ist
    Und ich befinde mich der Seite zur Erstellung einer neuen Vorlage
    Und ich habe den Namen der Vorlage eingegeben
    Wenn ich Modelle hinzufüge
    Und ich bei einem Modell eine Anzahl eingebe, welche höher ist als die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell
    Wenn ich speichere
    Dann ich sehe eine Warnmeldung wegen nicht erfüllbaren Vorlagen
    Und die neue Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert
    Und die Vorlage ist in der Liste als unerfüllbar markiert
    Wenn ich die gleiche Vorlage bearbeite
    Und ich die korrekte Anzahl angebe
    Und ich speichere
    Dann ich sehe die Erfolgsbestätigung
    Und die bearbeitete Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert
    Und die Vorlage ist in der Liste nicht als unerfüllbar markiert

  @javascript
  Szenario: Vorlage löschen
    Und ich befinde mich auf der Liste der Vorlagen
    Dann kann ich beliebige Vorlage direkt aus der Liste löschen
    Und die Vorlage wurde aus der Liste gelöscht
    Und die Vorlage wurde erfolgreich aus der Datenbank gelöscht

