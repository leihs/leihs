# language: de

Funktionalität: Rücknahme

  Um eine Gegenstände wieder dem Verleih zuzuführen
  möchte ich als Ausleih-Verwalter
  Gegenstände Zurücknehmen können

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Festhalten wer einen Gegenstand zurückgenommen hat
    Wenn ich einen Gegenstand zurücknehme
    Dann wird festgehalten, dass ich diesen Gegenstand zurückgenommen habe

  @javascript
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich befinde mich in einer Rücknahme für ein gesperrter Benutzer
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'

  @javascript
  Szenario: Zurückgeben einer Option
    Angenommen ich befinde mich in einer Rücknahme mit mindestens zwei gleichen Optionen
    Wenn ich eine Option über das Zuweisenfeld zurücknehme
    Dann wird die Zeile selektiert
    Und ich erhalte eine Erfolgsmeldung
    Und die Zeile ist nicht grün markiert
    Wenn ich alle Optionen der gleichen Zeile zurücknehme
    Dann wird die Zeile grün markiert
    Und ich erhalte eine Erfolgsmeldung
