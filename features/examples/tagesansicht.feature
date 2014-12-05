# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen ich bin Pius
    Und ich öffne die Tagesansicht

  @personas @javascript
  Szenario: Anzeige der längsten Zeitspanne für Bestellungen
    Angenommen eine Bestellungen mit zwei unterschiedlichen Zeitspannen existiert
    Und I navigate to the open orders
    Dann sehe ich für diese Bestellung die längste Zeitspanne direkt auf der Linie

  @personas @javascript
  Szenariogrundriss: Sperrstatus des Benutzers anzeigen
    Angenommen eigenes Benutzer sind gesperrt
    Und I navigate to the <target>
    Dann sehe ich auf allen Linien dieses Benutzers den Sperrstatus 'Gesperrt'
  Beispiele:
    | target           |
    | open orders      |
    | hand over visits |
    | take back visits |


