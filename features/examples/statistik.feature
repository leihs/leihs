# language: de

Funktionalität: Statistiken von Ausleihe und Inventar

  Grundlage:
    Angenommen ich bin Ramon

  @personas
  Szenario: Wo die Statistik-Ansicht erscheint
    Wenn ich im Verwalten-Bereich bin
    Dann habe ich die Möglichkeit zur Statistik-Ansicht zu wechseln

  @personas
  Szenario: Zeitliche Eingrenzung der Statistik-Ansicht
    Angenommen ich befinde mich in der Statistik-Ansicht
    Dann sehe ich normalerweise die Statistik der letzten 30 Tage
    Wenn ich den Zeitraum eingrenze auf 1.1. - 31.12. des laufenden Jahres
    Dann sehe ich nur statistische Daten die relevant sind für den 1.1. - 31.12. des laufenden Jahres
    Wenn es sich beim Angezeigten um eine Ausleihe handelt
    Dann sehe ich sie nur, wenn ihr Startdatum und ihr Rückgabedatum innerhalb der ausgewählten Zeit liegen

  @personas
  Szenario: Statistik über die Anzahl der Ausleihvorgänge pro Modell
    Angenommen ich befinde mich in der Statistik-Ansicht über Ausleihvorgänge
    Dann sehe ich dort alle Geräteparks, die Gegenstände besitzen
    Wenn ich einen Gerätepark expandiere
    Dann sehe ich alle Modelle, für die deren Gegenstände dieser Gerätepark verantwortlich ist
    Und ich sehe für das Modell die Anzahl Ausleihen
    Und ich sehe für das Modell die Anzahl Rücknahmen

  @personas
  Szenario: Statistik über Benutzer und deren Ausleihvorgänge
    Angenommen ich befinde mich in der Statistik-Ansicht über Benutzer
    Dann sehe ich für jeden Benutzer die Anzahl Aushändigungen
    Dann sehe ich für jeden Benutzer die Anzahl Rücknahmen

  @personas
  Szenario: Expandieren eines Modells
    Angenommen ich befinde mich in der Statistik-Ansicht
    Wenn ich dort ein Modell sehe
    Dann kann ich das Modell expandieren
    Und sehe dann die Gegenstände, die zu diesem Modell gehören

  @personas
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
