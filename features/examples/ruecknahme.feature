# language: de

Funktionalität: Rücknahme

  Um eine Gegenstände wieder dem Verleih zuzuführen
  möchte ich als Ausleih-Verwalter
  Gegenstände Zurücknehmen können

  Grundlage:
    Angenommen ich bin Pius

  @javascript @personas
  Szenario: Hinzufügen eines Gegenstandes in der Rücknahme
    Angenommen ich befinde mich in einer Rücknahme
    Wenn ich einen Gegenstand über das Zuweisenfeld zurücknehme
    Dann wird die Zeile selektiert
    Und die Zeile wird grün markiert
    Und ich erhalte eine Erfolgsmeldung

  @personas @javascript
  Szenario: Deselektieren einer Linie
    Angenommen ich befinde mich in einer Rücknahme
    Wenn ich einen Gegenstand über das Zuweisenfeld zurücknehme
    Und ich die Zeile deselektiere
    Dann ist die Zeile nicht mehr grün markiert

  @javascript @personas
  Szenario: Zurückzugebender Gegenstand hat Verspätung
    Angenommen ich befinde mich in einer Rücknahme mit mindestens einem verspäteten Gegenstand
    Wenn ich einen verspäteten Gegenstand über das Zuweisenfeld zurücknehme
    Dann wird die Zeile grün markiert
    Und die Zeile wird selektiert
    Und das Problemfeld für die Linie wird angezeigt
    Und ich erhalte eine Erfolgsmeldung

  @javascript @browser @personas
  Szenario: Festhalten wer einen Gegenstand zurückgenommen hat
    Wenn ich einen Gegenstand zurücknehme
    Dann wird festgehalten, dass ich diesen Gegenstand zurückgenommen habe

  @personas
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich befinde mich in einer Rücknahme für ein gesperrter Benutzer
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'

  @javascript @personas
  Szenario: Zurückgeben einer Option
    Angenommen ich befinde mich in einer Rücknahme mit mindestens zwei gleichen Optionen
    Wenn ich eine Option über das Zuweisenfeld zurücknehme
    Dann wird die Zeile selektiert
    Und ich erhalte eine Erfolgsmeldung
    Und die Zeile ist nicht grün markiert
    Wenn ich alle Optionen der gleichen Zeile zurücknehme
    Dann wird die Zeile grün markiert
    Und ich erhalte eine Erfolgsmeldung

  @javascript @browser @personas
  Szenario: Inspektion während einer Rücknahme
    Angenommen ich befinde mich in einer Rücknahme mit mindestens einem Gegenstand und einer Option
    Wenn ich bei der Option eine Stückzahl von 1 eingebe
    Und beim Gegenstand eine Inspektion durchführe
    Und ich setze "Zustand" auf "Defekt"
    Und I write a status note
    Und ich speichere
    Dann steht bei der Option die zuvor angegebene Stückzahl

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
