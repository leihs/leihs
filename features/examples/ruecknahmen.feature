# language: de

Funktionalität: Rücknahmen

  Um eine Gegenstände wieder dem Verleih zuzuführen
  möchte ich als Ausleih-Verwalter
  Gegenstände Zurücknehmen können

  Grundlage:
    Angenommen ich bin Pius

  @javascript @browser @personas
  Szenario: Festhalten wer einen Gegenstand zurückgenommen hat
    Wenn ich einen Gegenstand zurücknehme
    Dann wird festgehalten, dass ich diesen Gegenstand zurückgenommen habe

  @personas
  Szenario: Korrekte Reihenfolge mehrerer Verträge
    Und es existiert ein Benutzer mit mindestens 2 Rückgaben an 2 verschiedenen Tagen
    Wenn man die Rücknahmenansicht für den Benutzer öffnet
    Dann sind die Rücknahmen aufsteigend nach Datum sortiert

  @javascript @personas
  Szenario: Optionen in mehreren Zeitfenstern vorhanden
    Angenommen es existiert ein Benutzer mit einer zurückzugebender Option in zwei verschiedenen Zeitfenstern
    Und ich öffne die Rücknahmeansicht für diesen Benutzer
    Wenn ich diese Option zurücknehme
    Dann wird die Option dem ersten Zeitfenster hinzugefügt
    Wenn im ersten Zeitfenster bereits die maximale Anzahl dieser Option erreicht ist
    Und ich dieselbe Option nochmals hinzufüge
    Dann wird die Option dem zweiten Zeitfenster hinzugefügt
