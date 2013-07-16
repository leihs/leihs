# language: de

Funktionalität: Timeout Page


  Szenario: Ansicht
    Angenommen man ist "Normin"
    Wenn ich zur Timeout Page weitergeleitet werde
    Dann sehe ich meine Bestellung
    Und die nicht mehr verfügbaren Modelle sind hervorgehoben
    Und ich kann Einträge löschen
    Und ich kann Einträge editieren
    Und ich kann zur Hauptübersicht
  
  Szenario: Eintrag löschen
    Angenommen man ist "Normin"
    Wenn ich zur Timeout Page weitergeleitet werde
    Und ich lösche einen Eintrag
    Dann wird der Eintrag aus der Bestellung gelöscht

  Szenario: Eintrag ändern
    Angenommen man ist "Normin"
    Wenn ich zur Timeout Page weitergeleitet werde
    Und ich einen Eintrag ändere
    Dann werden die Änderungen gespeichert
    Und ich gelange wieder auf der Timeout Page

  Szenario: In Bestellung übernehmen nicht möglich
    Angenommen man ist "Normin"
    Und ich zur Timeout Page weitergeleitet werde
    Wenn ein Modell nicht verfügbar ist
    Und ich auf 'Weiter' drücke
    Dann lande ich wieder auf der Timeout Page
    Und ich erhalte ich einen Fehler

  Szenario: Bestellung löschen
    Angenommen man ist "Normin"
    Und ich zur Timeout Page weitergeleitet werde
    Wenn ich die Bestellung lösche
    Dann werden alle Modelle freigegeben
    Und ich gelange auf die Hauptübersicht



  
  
