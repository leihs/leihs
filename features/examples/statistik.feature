# language: de

Funktionalität: Statistiken von Ausleihe und Inventar

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"

  @javascript
  Szenario: Wo die Statistik-Ansicht erscheint
    Wenn ich in den Admin-Bereich wechsle
    Dann sehe ich als erstes direkt die Statistik-Ansicht

  @javascript
  Szenario: Zeitliche Eingrenzung der Statistik-Ansicht
    Angenommen ich bin in der Statistik-Ansicht
    Wenn ich den Zeitraum eingrenze auf 1.1. - 31.12. des laufenden Jahres
    Dann sehe ich nur statistische Daten die Relevant sind für den 1.1. - 31.12. des laufenden Jahres

  @javascript
  Szenario: Statistik über die Anzahl der Ausleihvorgänge pro Modell
    Angenommen ich bin in der Statistik-Ansicht über Ausleihvorgänge
    Wenn dort ein Modell erscheint
    Dann sehe ich für das Modell die Anzahl Ausleihen
    Dann sehe ich für das Modell die Anzahl Rücknahmen

  @javascript
  Szenario: Expandieren eines Modells
    Angenommen ich bin in der Statistik-Ansicht
    Wenn ich dort ein Modell sehe
    Dann kann ich das Modell expandieren
    Und sehe dann die Gegenstände, die zu diesem Modell gehören

  @javascript
  Szenario: Statistik über den Wert der Modelle und Gegenstände
    Angenommen ich bin in der Statistik-Ansicht über den Wert
    Wenn dort ein Modell erscheint
    Dann sehe ich für das Modell die Geräteparks, in denen Gegenstände dieses Modells existieren
    Dann sehe ich für das Modell die Summe des Anschaffungswerts aller Gegenstände dieses Modells
    Wenn ich ein solches Modell expandiere
    Dann sehe ich eine Liste aller Gegenstände dieses Modells
    Dann sehe ich für jeden Gegenstand seinen Anschaffungswert


