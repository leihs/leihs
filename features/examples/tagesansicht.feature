# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen man ist "Pius"
    Und ich öffne die Tagesansicht

  @javascript
  Szenario: Anzeige der längsten Zeitspanne für Bestellungen
    Angenommen eine Bestellungen mit zwei unterschiedlichen Zeitspannen existiert
    Dann sehe ich für diese Bestellung die längste Zeitspanne direkt auf der Linie
    
  @javascript
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen der Benutzer ist gesperrt
    Dann sehe ich auf allen Linien dieses Benutzers den Sperrstatus 'Gesperrt'
    
    
