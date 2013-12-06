# language: de

Funktionalität: Statistiken von Ausleihe und Inventar

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Ramon"

  @javascript
  Szenario: Wo die Statistik-Ansicht erscheint
    Wenn ich im Verwalten-Bereich bin
    Dann habe ich die Möglichkeit zur Statistik-Ansicht zu wechseln

  @javascript
  Szenario: Zeitliche Eingrenzung der Statistik-Ansicht
    Angenommen ich befinde mich in der Statistik-Ansicht
    Dann sehe ich normalerweise die Statistik der letzten 30 Tage
    Wenn ich den Zeitraum eingrenze auf 1.1. - 31.12. des laufenden Jahres
    Dann sehe ich nur statistische Daten die relevant sind für den 1.1. - 31.12. des laufenden Jahres
    Wenn es sich beim Angezeigten um eine Ausleihe handelt
    Dann sehe ich sie nur, wenn ihr Startdatum und ihr Rückgabedatum innerhalb der ausgewählten Zeit liegen

  @javascript
  Szenario: Statistik über die Anzahl der Ausleihvorgänge pro Modell
    Angenommen ich befinde mich in der Statistik-Ansicht über Ausleihvorgänge
    Dann sehe ich dort alle Geräteparks, die Gegenstände besitzen
    Wenn ich einen Gerätepark expandiere
    Dann sehe ich alle Modelle, für die deren Gegenstände dieser Gerätepark verantwortlich ist
    Und ich sehe für das Modell die Anzahl Ausleihen
    Und ich sehe für das Modell die Anzahl Rücknahmen
