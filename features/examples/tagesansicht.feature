# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen ich bin Pius
    Und ich öffne die Tagesansicht

  @personas
  Szenario: Anzeige der längsten Zeitspanne für Bestellungen
    Angenommen eine Bestellungen mit zwei unterschiedlichen Zeitspannen existiert
    Dann sehe ich für diese Bestellung die längste Zeitspanne direkt auf der Linie

  @personas
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen eigenes Benutzer sind gesperrt
    Dann sehe ich auf allen Linien dieses Benutzers den Sperrstatus 'Gesperrt'


