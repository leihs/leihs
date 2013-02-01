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

  @javascript
  Szenario: Scanning-Verhalten beim Aushändigen
    Wenn ich eine Aushändigung mache mit einem Kunden der sowohl am heutigen Tag sowie in der Zukunft Abholungen hat
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
  @javascript
  Szenario: Buchungskalender: Bei "Show Availability" anzeigen in welcher Grupper der Kunde ist
    Angenommen der Kunde ist in mehreren Gruppen
    Wenn ich eine Aushändigung an diesen Kunden mache
    Und eine Zeile mit Gruppen-Partitionen editiere
    Und die Gruppenauswahl aufklappe
    Dann erkenne ich, in welchen Gruppen der Kunde ist
    Und dann erkennen ich, in welchen Gruppen der Kunde nicht ist

  @javascript
  Szenario: Alle Suchresultate anzeigen
    Angenommen ich suche
    Dann erhalte ich Suchresultate in den Kategorien Benutzer, Modelle, Gegenstände, Verträge und Bestellungen
    Und ich sehe aus jeder Kategorie maximal die 3 ersten Resultate
    Wenn eine Kategorie mehr als 3 Resultate bringt
    Dann kann ich wählen, ob ich aus einer Kategorie mehr Resultate sehen will
    Wenn ich mehr Resultate wähle
    Dann sehe ich die ersten 10 Resultate
    Wenn die Kategorie mehr als 10 Resultate bringt
    Dann kann ich wählen, ob ich alle Resultate sehen will
    Wenn ich alle Resultate wähle erhalte ich eine separate Liste aller Resultate dieser Kategorie

  @javascript
  Szenario: Zusammenziehen der Anzahlen im Item-Popup
    Angenommen man fährt über die Anzahl von Gegenständen in einer Zeile
    Dann werden alle diese Gegenstände aufgelistet
    Und man sieht pro Modell eine Zeile
    Und man sieht auf jeder Zeile die Summe der Gegenstände des jeweiligen Modells

  @javascript
  Szenario: Inspektion bei Rücknahme
    Angenommen ich mache eine Rücknahme
    Dann habe ich für jeden Gegenstand die Möglichkeit, eine Inspektion auszulösen
    Wenn ich bei einem Gegenstand eine Inspektion durchführen
    Und die Inspektion erlaubt es, den Status von "Zustand" auf "Funktionstüchtig" oder "Defekt" zu setzen
    Und die Inspektion erlaubt es, den Status von "Vollständigkeit" auf "Vollständig" oder "Unvollständig" zu setzen
    Und die Inspektion erlaubt es, den Status von "Ausleihbar" auf "Ausleihbar" oder "Nicht ausleihbar" zu setzen
    Wenn ich Werte der Inspektion ändere
    Und wenn ich die Inspektion speichere
    Dann wird der Gegenstand mit den aktuell gesetzten Status gespeichert

  @javascript
    Szenario: Automatischer Druck Dialog beim Aushändigen
    Wenn ich eine Aushändigung mache
    Dann wird automatisch der Druck-Dialog geöffnet

