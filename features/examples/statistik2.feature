# language: de

Funktionalität: Statistiken von Ausleihe und Inventar

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Ramon"

  @javascript
  Szenario: Statistik über Benutzer und deren Ausleihvorgänge
    Angenommen ich befinde mich in der Statistik-Ansicht über Benutzer
    Dann sehe ich für jeden Benutzer die Anzahl Aushändigungen
    Dann sehe ich für jeden Benutzer die Anzahl Rücknahmen

  @javascript
  Szenario: Expandieren eines Modells
    Angenommen ich befinde mich in der Statistik-Ansicht
    Wenn ich dort ein Modell sehe
    Dann kann ich das Modell expandieren
    Und sehe dann die Gegenstände, die zu diesem Modell gehören

  @javascript
  Szenario: Statistik über den Wert der Modelle und Gegenstände
    Angenommen ich befinde mich in der Statistik-Ansicht über den Wert
    Dann sehe ich dort alle Geräteparks, die Gegenstände besitzen
    Wenn ich einen Gerätepark expandiere
    Dann sehe ich alle Modelle, für die dieser Gerätepark Gegenstände besitzt
    Und für jedes  Modell die Summe des Anschaffungswerts aller Gegenstände dieses Modells in diesem Gerätepark
    Und für jedes  Modell die Anzahl aller Gegenstände dieses Modells in diesem Gerätepark
    Wenn ich ein solches Modell expandiere
    Dann sehe ich eine Liste aller Gegenstände dieses Modells
    Dann sehe ich für jeden Gegenstand seinen Anschaffungswert
