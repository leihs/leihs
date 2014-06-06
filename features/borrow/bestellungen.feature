# language: de

Funktionalität: Bestellungen

  Grundlage:
    Angenommen ich bin Normin

  @personas
  Szenario: Anzahl
    Dann sehe ich die Anzahl meiner abgeschickten, noch nicht genehmigten Bestellungen auf jeder Seite

  @personas
  Szenario: Bestellungen-Übersichtsseite
    Wenn ich auf den Bestellungen Link drücke
    Dann sehe ich meine abgeschickten, noch nicht genehmigten Bestellungen
    Und ich sehe die Information, dass die Bestellung noch nicht genehmigt wurde
    Und die Bestellungen sind nach Datum und Gerätepark sortiert
    Und jede Bestellung zeigt die zu genehmigenden Geräte
    Und die Geräte der Bestellung sind alphabetisch sortiert nach Modellname