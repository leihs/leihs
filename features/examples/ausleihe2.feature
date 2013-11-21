# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

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

