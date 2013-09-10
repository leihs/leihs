# language: de

Funktionalität: Vorlagen verwalten

  Als Ausleihe-Verwalter / Inventar-Verwalter möchte ich 
  die Möglichkeit haben, Vorlagen zu verwalten

  Szenario: Liste aller Vorlagen anzeigen
    Angenommen ich bin Mike
    Wenn ich im Inventarbereich auf den Link "Vorlagen" klicke
    Dann öffnet sich die Seite mit der Liste der im aktuellen Inventarpool erfassten Vorlagen
    Und die Vorlagen für dieses Inventarpool sind alphabetisch nach Namen sortiert

  @javascript
  Szenario: Vorlage erstellen
    Angenommen ich bin Mike
    Und ich befinde mich auf der Liste der Vorlagen
    Wenn ich auf den Button "Neue Vorlage" klicke
    Dann öffnet sich die Seite zur Erstellung einer neuen Vorlage
    Wenn ich den Namen der Vorlage eingebe
    Und ich Modelle hinzufüge
    Dann steht bei jedem Modell die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell
    Und für jedes hinzugefügte Modell ist die Mindestanzahl 1
    Wenn ich zu jedem Modell die Anzahl angebe
    Und ich speichere die Vorlage
    Dann ich wurde auf die Liste der Vorlagen weitergeleitet
    Und ich sehe die Erfolgsbestätigung
    Und die neue Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert

  @javascript
  Szenario: Prüfen, ob max. Anzahl bei den Modellen überschritten ist
    Angenommen ich bin Mike
    Und ich befinde mich der Seite zur Erstellung einer neuen Vorlage
    Und ich habe den Namen der Vorlage eingegeben
    Wenn ich Modelle hinzufüge
    Und ich bei einem Modell eine Anzahl eingebe, welche höher ist als die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell
    Wenn ich speichere die Vorlage
    Dann ich sehe eine Fehlermeldung
    Und die neue Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert
    Und die Vorlage ist in der Liste als unerfüllbar markiert
    Wenn ich die gleiche Vorlage bearbeite
    Und ich die korrekte Anzahl angebe
    Und ich speichere die Vorlage
    Dann ich sehe die Erfolgsbestätigung
    Und die bearbeitete Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert
    Und die Vorlage ist in der Liste nicht als unerfüllbar markiert

  @javascript
  Szenario: Vorlage löschen
    Angenommen ich bin Mike
    Und ich befinde mich auf der Liste der Vorlagen
    Dann kann ich beliebige Vorlage direkt aus der Liste löschen
    Und es wird mir dabei vorher eine Warnung angezeigt
    Und die Vorlage wurde aus der Liste gelöscht
    Und die Vorlage wurde erfolgreich aus der Datenbank gelöscht
  
  @javascript
  Szenario: Vorlage ändern
    Angenommen ich bin Mike
    Und ich befinde mich auf der Liste der Vorlagen
    Und es existiert eine Vorlage mit mindestens zwei Modellen
    Wenn ich auf den Button "Vorlage bearbeiten" klicke
    Dann öffnet sich die Seite zur Bearbeitung einer existierenden Vorlage
    Wenn ich den Namen ändere
    Und die Anzahl bei einem der Modell ändere
    Und ich ein zusätzliches Modell hinzufüge
    Und für jedes hinzugefügte Modell ist die Mindestanzahl 1
    Und ein Modell aus der Liste lösche
    Und ich speichere die bearbeitete Vorlage
    Dann ich wurde auf die Liste der Vorlagen weitergeleitet
    Und ich sehe die Erfolgsbestätigung
    Und die bearbeitete Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert

  @javascript
  Szenario: Pflichtangaben bei der Editieransicht
    Angenommen ich bin Mike
    Und ich befinde mich auf der Editieransicht einer Vorlage
    Wenn der Name nicht ausgefüllt ist
    Und es ist mindestens ein Modell dem Template hinzugefügt
    Und ich speichere die bearbeitete Vorlage
    Dann sehe ich eine Fehlermeldung
    Wenn ich den Name ausgefüllt habe
    Und kein Modell hinzugefügt habe
    Und ich speichere die bearbeitete Vorlage
    Dann sehe ich eine Fehlermeldung

  @javascript
  Szenario: Pflichtangaben bei der Erstellungsansicht
    Angenommen ich bin Mike
    Und ich befinde mich auf der Erstellungsansicht einer Vorlage
    Wenn der Name nicht ausgefüllt ist
    Und es ist mindestens ein Modell dem Template hinzugefügt
    Und ich speichere die bearbeitete Vorlage
    Dann sehe ich eine Fehlermeldung
    Wenn ich den Name ausgefüllt habe
    Und kein Modell hinzugefügt habe
    Und ich speichere die Vorlage
    Dann sehe ich eine Fehlermeldung
