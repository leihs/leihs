# language: de

Funktionalität: Vorlagen verwalten

  Als Ausleihe-Verwalter / Inventar-Verwalter möchte ich 
  die Möglichkeit haben, Vorlagen zu verwalten
  
  Szenario: Liste aller Vorlagen anzeigen
    Angenommen ich bin "Mike"
    Wenn ich im Inventarbereich auf den Link "Vorlagen" klicke
    Dann öffnet sich die Seite mit der Liste der im aktuellen Inventarpool erfassten Vorlagen
    
  Szenario: Vorlage erstellen
    Angenommen ich bin "Mike"
    Und ich befinde mich auf der Liste der Vorlagen
    Wenn ich auf den Button "Neue Vorlage erstellen" klicke
    Dann öffnet sich die Seite zur Erstellung einer neuen Vorlage
    Wenn ich den Namen der Vorlage eingebe
    Und ich Modelle hinzufüge
    Dann steht bei jedem Modell die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell
    Und für jedes hinzugefügte Modell ist die Mindestanzahl 1
    Wenn ich zu jedem Modell die Anzahl angebe
    Und ich speichere die Vorlage
    Dann wurde die neue Vorlage mit all den erfassten Informationen erfolgreich gespeichert
    Und ich wurde auf die Liste der Vorlagen weitergeleitet
    Und ich sehe die Erfolgsbestätigung

  Szenario: Prüfen, ob max. Anzahl bei den Modellen überschritten ist
    Angenommen ich bin "Mike"
    Und ich befinde mich der Seite zur Erstellung einer neuen Vorlage
    Und ich habe den Namen der Vorlage eingegeben
    Wenn ich Modelle hinzufüge
    Und ich bei einem Modell eine Anzahl eingebe, welche höher ist als die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell
    Dann ist dieses Modell mit der entsprechenden Meldung hervorgehoben
    Wenn ich die Vorlage speichere
    Dann sehe ich eine Fehlermeldung
    Wenn ich die korrekte Anzahl angebe
    Dann verschwindet die hervorgehobene Markierung bei diesem Modell
    Wenn ich die Vorlage speichere
    Dann wurde die neue Vorlage mit all den erfassten Informationen erfolgreich gespeichert

  Szenario: Vorlage löschen
    Angenommen ich bin "Mike"
    Und ich befinde mich auf der Liste der Vorlagen
    Dann kann ich beliebige Vorlage direkt aus der Liste löschen
    Und es wird mir dabei vorher eine Warnung angezeigt
  
  Szenario: Vorlage ändern
    Angenommen ich bin "Mike"
    Und ich befinde mich auf der Liste der Vorlagen
    Wenn ich auf den Button "Vorlage bearbeiten" klicke
    Dann öffnet sich die Seite zur Bearbeitung einer existierenden Vorlage
    Wenn ich den Namen ändere
    Und ich ein zusätzliches Modell hinzufüge
    Und für jedes hinzugefügte Modell ist die Mindestanzahl 1
    Und ein Modell aus der Liste lösche
    Und die Anzahl bei einem der Modell ändere
    Und ich speichere die bearbeitete Vorlage
    Dann wurde die bearbeitete Vorlage mit all den erfassten Informationen erfolgreich gespeichert
    Und ich wurde auf die Liste der Vorlagen weitergeleitet
    Und ich sehe die Erfolgsbestätigung

  Szenario: Pflichtangaben bei der Editieransicht
    Angenommen ich bin "Mike"
    Und ich befinde mich auf der Editieransicht einer Vorlage
    Wenn der Name nicht ausgefüllt ist
    Und ich speichere die bearbeitete Vorlage
    Dann sehe ich eine Fehlermeldung
    Wenn ich den Name ausgefüllt habe
    Und keine Modell hinzugefügt habe
    Und ich speichere die bearbeitete Vorlage
    Dann sehe ich eine Fehlermeldung

  Szenario: Pflichtangaben bei der Erstellungsansicht
    Angenommen ich bin "Mike"
    Und ich befinde mich auf der Erstellungsansicht einer Vorlage
    Wenn der Name nicht ausgefüllt ist
    Und ich speichere die bearbeitete Vorlage
    Dann sehe ich eine Fehlermeldung
    Wenn ich den Name ausgefüllt habe
    Und keine Modell hinzugefügt habe
    Und ich speichere die neue Vorlage
    Dann sehe ich eine Fehlermeldung
