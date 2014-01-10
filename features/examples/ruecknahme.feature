# language: de

Funktionalität: Rücknahme

  Um eine Gegenstände wieder dem Verleih zuzuführen
  möchte ich als Ausleih-Verwalter
  Gegenstände Zurücknehmen können

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Hinzufügen eines Gegenstandes in der Rücknahme
    Angenommen ich befinde mich in einer Rücknahme
    Wenn ich einen Gegenstand über das Zuweisenfeld zurücknehme
    Dann wird die Zeile selektiert
    Und die Zeile wird grün markiert
    Und ich erhalte eine Erfolgsmeldung

  @javascript
  Szenario: Deselektieren einer Linie
    Angenommen ich befinde mich in einer Rücknahme
    Wenn ich einen Gegenstand über das Zuweisenfeld zurücknehme
    Und ich die Zeile deselektiere
    Dann ist die Zeile nicht mehr grün markiert

  @javascript
  Szenario: Zurückzugebender Gegenstand hat Verspätung
    Angenommen ich befinde mich in einer Rücknahme mit mindestens einem verspäteten Gegenstand
    Wenn ich einen verspäteten Gegenstand über das Zuweisenfeld zurücknehme
    Dann wird die Zeile grün markiert
    Und die Zeile wird selektiert
    Und das Problemfeld für die Linie wird angezeigt
    Und ich erhalte eine Erfolgsmeldung
