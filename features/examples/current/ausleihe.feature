# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen man ist "Pius"
    Und man öffnet die Tagesansicht

  @javascript
  Szenario: Klick auf Letzten Besuche
    Wenn ich eine Bestellung von "Normin N." bearbeite
    Dann man öffnet die Tagesansicht
    Dann sehe ich die letzten Besucher
    Und sehe ich "Normin N." in die letzten Besucher
    Wenn klicke ich auf "Normin N."
    Dann soll ich zu einem Suchresultat nach "Normin N." führen
