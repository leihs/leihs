# language: de

Funktionalität: Vorlagen verwalten

  Als Ausleihe-Verwalter / Inventar-Verwalter möchte ich 
  die Möglichkeit haben, Vorlagen zu verwalten

  Grundlage:
    Angenommen man ist "Mike"

  @javascript
  Szenario: Vorlage ändern
    Und ich befinde mich auf der Liste der Vorlagen
    Und es existiert eine Vorlage mit mindestens zwei Modellen
    Wenn ich auf den Button "Vorlage bearbeiten" klicke
    Dann öffnet sich die Seite zur Bearbeitung einer existierenden Vorlage
    Wenn ich den Namen ändere
    Und ein Modell aus der Liste lösche
    Und ich ein zusätzliches Modell hinzufüge
    Dann für das hinzugefügte Modell ist die Mindestanzahl 1
    Und die Anzahl bei einem der Modell ändere
    Und ich speichere
    Dann ich wurde auf die Liste der Vorlagen weitergeleitet
    Und ich sehe die Erfolgsbestätigung
    Und die bearbeitete Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert

  @javascript
  Szenario: Pflichtangaben bei der Editieransicht
    Und ich befinde mich auf der Editieransicht einer Vorlage
    Wenn der Name nicht ausgefüllt ist
    Und es ist mindestens ein Modell dem Template hinzugefügt
    Und ich speichere
    Dann sehe ich eine Fehlermeldung
    Wenn ich den Name ausgefüllt habe
    Und kein Modell hinzugefügt habe
    Und ich speichere
    Dann sehe ich eine Fehlermeldung

  @javascript
  Szenario: Pflichtangaben bei der Erstellungsansicht
    Und ich befinde mich auf der Erstellungsansicht einer Vorlage
    Wenn der Name nicht ausgefüllt ist
    Und es ist mindestens ein Modell dem Template hinzugefügt
    Und ich speichere
    Dann sehe ich eine Fehlermeldung
    Wenn ich den Name ausgefüllt habe
    Und kein Modell hinzugefügt habe
    Und ich speichere
    Dann sehe ich eine Fehlermeldung