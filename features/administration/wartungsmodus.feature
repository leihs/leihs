# language: de

Funktionalität: Wartungsmodus

Als Administrator möchte ich die Möglichkeit haben,
für die Bereiche "Verwalten" und "Verleih" bei Wartungsarbeiten das System zu sperren und dem Benutzer eine Meldung anzuzeigen

  Grundlage:
    Angenommen ich bin Gino

  @javascript @personas
  Szenario: Verwalten-Bereich sperren
    Angenommen ich befinde mich in den Pool-übergreifenden Einstellungen
    Wenn ich die Funktion "Verwaltung sperren" wähle
    Dann muss ich eine Bemerkung angeben
    Wenn ich eine Bemerkung für "Verwalten-Bereich" angebe
    Und ich speichere
    Dann wurde die Einstellung für "Verwalten-Bereich" erfolgreich gespeichert
    Und der Bereich "Verwalten" ist für die Benutzer gesperrt
    Und dem Benutzer wird die eingegebene Bemerkung angezeigt

  @javascript @personas
  Szenario: Ausleihen-Bereich sperren
    Angenommen ich befinde mich in den Pool-übergreifenden Einstellungen
    Wenn ich die Funktion "Ausleihen sperren" wähle
    Dann muss ich eine Bemerkung angeben
    Wenn ich eine Bemerkung für "Ausleihen-Bereich" angebe
    Und ich speichere
    Dann wurde die Einstellung für "Ausleihen-Bereich" erfolgreich gespeichert
    Und der Bereich "Ausleihen" ist für die Benutzer gesperrt
    Und dem Benutzer wird die eingegebene Bemerkung angezeigt

  @javascript @personas
  Szenario: Verwalten-Bereich entsperren
    Angenommen der "Verwalten" Bereich ist gesperrt
    Und ich befinde mich in den Pool-übergreifenden Einstellungen
    Wenn ich die Funktion "Verwaltung sperren" deselektiere
    Und ich speichere
    Dann ist der Bereich "Verwalten" für den Benutzer nicht mehr gesperrt
    Und die eingegebene Meldung für "Verwalten" Bereich ist immer noch gespeichert

  @javascript @personas
  Szenario: Ausleihen-Bereich entsperren
    Angenommen der "Ausleihen" Bereich ist gesperrt
    Und ich befinde mich in den Pool-übergreifenden Einstellungen
    Wenn ich die Funktion "Ausleihen sperren" deselektiere
    Und ich speichere
    Dann ist der Bereich "Ausleihen" für den Benutzer nicht mehr gesperrt
    Und die eingegebene Meldung für "Ausleihen" Bereich ist immer noch gespeichert
