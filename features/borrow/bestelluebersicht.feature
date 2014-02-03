# language: de

Funktionalität: Bestellübersicht

  Um die Bestellung in der Übersicht zu sehen
  möchte ich als Ausleiher
  die Möglichkeit haben meine bestellten Gegenstände in der Übersicht zu sehen

  Grundlage:
    Angenommen man ist "Normin"
    Und ich habe Gegenstände der Bestellung hinzugefügt
    Wenn ich die Bestellübersicht öffne

  Szenario: Bestellübersicht Auflistung der Gegenstände
    Dann sehe ich die Einträge gruppiert nach Startdatum und Gerätepark
    Und die Modelle sind alphabetisch sortiert
    Und für jeden Eintrag sehe ich die folgenden Informationen
    |Bild|
    |Anzahl|
    |Modellname|
    |Hersteller|
    |Anzahl der Tage|
    |Enddatum|
    |die versch. Aktionen|

  @javascript
  Szenario: Bestellübersicht Aktion 'löschen'
    Wenn ich einen Eintrag lösche
    Dann die Gegenstände sind wieder zur Ausleihe verfügbar
     Und wird der Eintrag aus der Bestellung entfernt
