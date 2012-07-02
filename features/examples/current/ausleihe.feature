# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    
  @javascript
  Szenario: Klick auf Letzten Besucher
    Angenommen ich öffne die Tagesansicht
    Und ich öffnet eine Bestellung von "Normin N."
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

  Szenario: Scanning-Verhalten beim Aushändigen
    Wenn ich etwas scanne (per Inventarcode zuweise) und es in irgendeinem zukünftigen Vertrag existiert
    Dann wird es zugewiesen (unabhängig ob es ausgewählt ist)
    Wenn es in keinem zukünftigen Vertrag existiert 
    Dann wird es für die ausgewählte Zeitspanne hinzugefügt

  @javascript
  Szenario: Fehlermeldung beim Versuch, etwas aus der Zukunft auszuhändigen
    Wenn ich eine Aushändigung mache
     Und die ausgewählten Gegenstände auch solche beinhalten, die in einer zukünftige Aushändigung enthalten sind
     Und ich versuche, die Gegenstände auszuhändigen
    Dann sehe ich eine Fehlermeldung
     Und die Fehlermeldung lautet "Mindestens ein Startdatum liegt in der Zukunft"
     Und ich kann die Gegenstände nicht aushändigen

  # https://www.pivotaltracker.com/story/show/29455957
  Szenario: Buchungskalender: Bei "Show Availability" anzeigen in welcher Grupper der Kunde ist
    Angenommen der Kunde ist in mehreren Gruppen
    Wenn ich eine Aushändigung an diesen Kunden mache
    Und eine Zeile editiere
    Und die Gruppenauswahl aufklappe
    Dann erkenne ich, in welchen Gruppen der Kunde ist
    Und dann erkennen ich, in welchen Gruppen der Kunde nicht ist