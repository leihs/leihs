# language: de

Funktionalität: Bestellübersicht

  Um die Bestellung in der Übersicht zu sehen
  möchte ich als Ausleiher
  die Möglichkeit haben meine bestellten Gegenstände in der Übersicht zu sehen

  Grundlage:
    Angenommen man ist "Normin"
    Und ich habe Gegenstände der Bestellung hinzugefügt
    Wenn ich die Bestellübersicht öffne

  @javascript
  Szenario: Bestellübersicht Aktion 'ändern'
    Wenn ich den Eintrag ändere
    Dann öffnet der Kalender
    Und ich ändere die aktuellen Einstellung
    Und speichere die Einstellungen
    Dann wird der Eintrag gemäss aktuellen Einstellungen geändert
    Und der Eintrag wird in der Liste anhand der des aktuellen Startdatums und des Geräteparks gruppiert

  @javascript
  Szenario: Zeitentität, Ablauf der erlaubten Zeit anzeigen
    Dann sehe ich die Zeitinformationen in folgendem Format "mm:ss"
    Und die Zeitanzeige zählt von 30 Minuten herunter

  @javascript
  Szenario: Zeit zurücksetzen
    Angenommen die Bestellung ist nicht leer
    Dann sehe ich die Zeitanzeige
    Wenn ich den Time-Out zurücksetze
    Dann wird die Zeit zurückgesetzt