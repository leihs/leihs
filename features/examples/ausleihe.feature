# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    
  @javascript
  Szenario: Klick auf Letzten Besucher
    Angenommen ich öffne die Tagesansicht
    Und ich öffne eine Bestellung von "Normin N."
    Dann ich kehre zur Tagesansicht zurück
    Dann sehe ich die letzten Besucher
    Und ich sehe "Normin N." als letzten Besucher
    Wenn ich auf "Normin N." klicke
    Dann wird mir ich ein Suchresultat nach "Normin N." angezeigt

  @javascript
  Szenario: Autocomplete bei der Rücknahme
    Wenn ich eine Rücknahme mache
    Und etwas in das Feld "Inventarcode/Name" schreibe
    Dann werden mir diejenigen Gegenstände vorgeschlagen, die in den dargestellten Rücknahmen vorkommen
    Wenn ich etwas zuweise, das nicht in den Rücknahmen vorkommt
    Dann sehe ich eine Fehlermeldung
    Und die Fehlermeldung lautet "In dieser Rücknahme nicht gefunden"

  @javascript
  Szenario: Selektion bei manueller Interaktion bei Aushändigung
    Wenn ich eine Aushändigung mache
    Und einem Gegenstand einen Inventarcode manuell zuweise
    Dann wird der Gegenstand ausgewählt und der Haken gesetzt

  @javascript
  Szenario: Selektion bei manueller Interaktion bei Rücknahme
    Wenn ich eine Rücknahme mache die Optionen beinhaltet
    Und die Anzahl einer zurückzugebenden Option manuell ändere
    Dann wird die Option ausgewählt und der Haken gesetzt

  @javascript
  Szenario: Aushändigen: In den Inventarcodelisten nicht verfügbare Gegenstände hervorheben
    Wenn ich eine Aushändigung mache die ein Model enthält dessen Gegenstände ein nicht ausleihbares enthält
    Und diesem Model ein Inventarcode zuweisen möchte
    Dann schlägt mir das System eine Liste von Gegenständen vor
    Und diejenigen Gegenstände sind gekennzeichnet, welche als nicht ausleihbar markiert sind

