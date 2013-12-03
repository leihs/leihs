# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Selektion bei manueller Interaktion bei Aushändigung
    Wenn ich eine Aushändigung mache
    Und einem Gegenstand einen Inventarcode manuell zuweise
    Dann wird der Gegenstand ausgewählt und der Haken gesetzt

  @javascript
  Szenario: Aushändigen: In den Inventarcodelisten nicht verfügbare Gegenstände hervorheben
    Wenn ich eine Aushändigung mache die ein Model enthält dessen Gegenstände ein nicht ausleihbares enthält
    Und diesem Model ein Inventarcode zuweisen möchte
    Dann schlägt mir das System eine Liste von Gegenständen vor
    Und diejenigen Gegenstände sind gekennzeichnet, welche als nicht ausleihbar markiert sind

  @javascript
  Szenario: Wann letzter Besucher erscheint
    Angenommen ich öffne die Tagesansicht
    Wenn ich eine Bestellung editieren
    Dann erscheint der Benutzer unter den letzten Besuchern
    Wenn ich eine Aushändigung mache
    Dann erscheint der Benutzer unter den letzten Besuchern
    Wenn ich eine Rücknahme mache
    Dann erscheint der Benutzer unter den letzten Besuchern
