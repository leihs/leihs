# language: de

Funktionalität: Rücknahme

  Um eine Gegenstände wieder dem Verleih zuzuführen
  möchte ich als Ausleih-Verwalter
  Gegenstände Zurücknehmen können

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Festhalten wer einen Gegenstand zurückgenommen hat
    Angenommen man ist "Pius"
    Wenn ich einen Gegenstand zurücknehme
    Dann wird festgehalten, dass ich diesen Gegenstand zurückgenommen habe
    
  @javascript
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen der Benutzer ist gesperrt
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'
