# language: de

Funktionalität: Rücknahmen

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
  Szenario: Korrekte Reihenfolge mehrerer Verträge
    Angenommen man ist "Pius"
    Und es existiert ein Benutzer mit mindestens 2 Rückgaben an 2 verschiedenen Tagen
    Wenn man die Rücknahmenansicht für den Benutzer öffnet
    Dann sind die Rücknahmen aufsteigend nach Datum sortiert
