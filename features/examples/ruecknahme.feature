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

  @javascript
  Szenario: Hinzufügen eines Gegenstandes in der Rücknahme
    Angenommen ich befinde mich in einer Rücknahme
    Wenn ich einen Gegenstand zuteile
    Dann wird die Zeile selektiert
    Und die Zeile wird grün markiert
    Und ich erhalte eine Erfolgsmeldung
  
  @javascript
  Szenario: Bereits zugeteilter Gegenstand wird entfernt
    Angenommen ich befinde mich in einer Rücknahme
    Wenn ich die Zeile deselektiere
    Dann ist die Zeile nicht mehr grün markiert
  
  @javascript
  Szenario: Zurückzugebender Gegenstand hat Verspätung
    Angenommen ich befinde mich in einer Rücknahme
    Wenn ich einen Gegenstand zuteile, der ein Probelem hat
    Dann wird die Zeile grün markiert
    Und die Zeile wird selektiert
    Und das Problemfeld wird mir angezeigt
    Und ich erhalte eine grüne Erfolgsmeldung
  
  @javascript
  Szenario: Zurückgeben einer Option
    Angenommen ich befinde mich in einer Rücknahme
    Wenn ich eine Option zuteile
    Dann wird die Zeile selektiert
    Und ich erhalte eine grüne Erfolgsmeldung
    Wenn ich alle Optionen der gleichen Zeile zuteile
    Dann wird die Zeile grün selektiert
    Und ich erhalte eine grüne Erfolgsmeldung
