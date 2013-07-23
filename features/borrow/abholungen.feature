# language: de

Funktionalität: Abholungen

  Szenario: Anzahl und Rückgabe-Button
    Angenommen man ist "Normin"
    Dann sehe ich die Anzahl meiner "Abholungen" auf jeder Seite

  Szenario: Kein Abhol-Button im Fall nicht vorhandenen Rückgaben
    Angenommen man ist "Ramon"
    Und man befindet sich im Ausleihen-Bereich
    Dann sehe ich den "Abholungen" Button nicht

  Szenario: Abholungen-Übersichtsseite
    Angenommen man ist "Normin"
    Wenn ich auf den "Abholungen" Link drücke
    Dann sehe ich meine "Abholungen"
    Und die "Abholungen" sind nach Datum und Gerätepark sortiert
    Und jede der "Abholungen" zeigt die abzuholenden Geräte
    Und die Geräte sind alphabetisch sortiert und gruppiert nach Modellname mit Anzahl der Geräte
