# language: de

Funktionalität: Wartungsmodus

Als Administrator möchte ich die Möglichkeit haben,
für die Bereiche "Verwalten" und "Verleih" bei Wartungsarbeiten das System zu sperren und dem Benutzer eine Meldung anzuzeigen

Grundlage:
Angenommen Personas existieren

  Szenario: "Verwalen"-Bereich sperren
    Angenommen man ist "Gino"
    Und ich befinde mich in den Pool-übergreifenden Einstellungen
    Wenn ich die Funktion "Verwaltung sperren" wähle
    Dann muss ich eine Bemerkung angeben
    Und der Bereich "Verwalten" ist für die Benutzer gesperrt
    Und dem Benutzer wird die eingegebene Bemerkung angezeigt
    
  Szenario: "Ausleihen"-Bereich sperren
    Angenommen man ist "Gino"
    Und ich befinde mich in den Pool-übergreifenden Einstellungen
    Wenn ich die Funktion "Ausleihe sperren" wähle
    Dann muss ich eine Bemerkung angeben
    Und der Bereich "Ausleihen" ist für die Benutzer gesperrt
    Und dem Benutzer wird die eingegebene Bemerkung angezeigt
    

  Szenario: "Verwalen"-Bereich entsperren
    Angenommen man ist "Gino"
    Und ich befinde mich in den Pool-übergreifenden Einstellunge 
    Wenn ich die Funktion "Verwaltung sperren" deselektiere
    Dann ist die eingegebene Meldung noch immer gespeichert
    Und der Bereich "Verwalten" ist für den Benutzer nicht mehr gesperrt
    
  Szenario: "Ausleihen"-Bereich entsperren
    Angenommen man ist "Gino"
    Und ich befinde mich in den Pool-übergreifenden Einstellunge 
    Wenn ich die Funktion "Ausleihen sperren" deselektiere
    Dann ist die eingegebene Meldung noch immer gespeichert
    Und der Bereich "Ausleihen" ist für den Benutzer nicht mehr gesperrt    
    
 
