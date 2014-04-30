# language: de

Funktionalität: Rückgaben

  Szenario: Anzahl und Rückgabe-Button
    Angenommen ich bin Normin
    Dann sehe ich die Anzahl meiner "Rückgaben" auf jeder Seite

  Szenario: Kein Rückgabe-Button im Fall nicht vorhandenen Rückgaben
    Angenommen ich bin Ramon
    Und man befindet sich im Ausleihen-Bereich
    Dann sehe ich den "Rückgaben" Button nicht

  Szenario: Rückgabe-Übersichtsseite
    Angenommen ich bin Normin
    Wenn ich auf den "Rückgaben" Link drücke
    Dann sehe ich meine "Rückgaben"
    Und die "Rückgaben" sind nach Datum und Gerätepark sortiert
    Und jede der "Rückgaben" zeigt die zurückzugebenden Geräte
    Und die Geräte sind alphabetisch sortiert nach Modellname
    Und jedes Gerät zeigt seinen Inventarcode
