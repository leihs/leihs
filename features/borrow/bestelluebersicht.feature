# language: de

Funktionalität: Bestellübersicht

  Um die Bestellung in der Übersicht zu sehen
  möchte ich als Ausleiher
  die Möglichkeit haben meine bestellten Gegenstände in der Übersicht zu sehen

  Grundlage:
    Angenommen ich bin Normin
    Und ich habe Gegenstände der Bestellung hinzugefügt
    Wenn ich die Bestellübersicht öffne

  @personas
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

  @javascript @browser @personas
  Szenario: Bestellübersicht Aktion 'löschen'
    Wenn ich einen Eintrag lösche
    Dann die Gegenstände sind wieder zur Ausleihe verfügbar
     Und wird der Eintrag aus der Bestellung entfernt

  @javascript @personas
  Szenario: Zeit überschritten
    Wenn ich ein Modell der Bestellung hinzufüge
    Dann sehe ich die Zeitanzeige
    Wenn man befindet sich auf der Bestellübersicht
    Und  die Zeit überschritten ist
    Dann werde ich auf die Timeout Page weitergeleitet

  @javascript @personas
  Szenario: Bestellübersicht Aktion 'ändern'
    Wenn ich den Eintrag ändere
    Dann öffnet der Kalender
    Und ich ändere die aktuellen Einstellung
    Und speichere die Einstellungen
    Dann wird der Eintrag gemäss aktuellen Einstellungen geändert
    Und der Eintrag wird in der Liste anhand der des aktuellen Startdatums und des Geräteparks gruppiert

  @javascript @personas
  Szenario: Zeitentität, Ablauf der erlaubten Zeit anzeigen
    Dann sehe ich die Zeitinformationen in folgendem Format "mm:ss"
    Und die Zeitanzeige zählt von 30 Minuten herunter

  @personas
  Szenario: Zeit zurücksetzen
    Angenommen die Bestellung ist nicht leer
    Dann sehe ich die Zeitanzeige
    Wenn ich den Time-Out zurücksetze
    Dann wird die Zeit zurückgesetzt

  @javascript @personas
  Szenario: Zeit abgelaufen
    Wenn die Zeit abgelaufen ist
    Dann werde ich auf die Timeout Page weitergeleitet

  @javascript @browser @personas
  Szenario: Bestellübersicht Bestellung löschen
    Wenn ich die Bestellung lösche
    Dann werde ich gefragt ob ich die Bestellung wirklich löschen möchte
    Und alle Einträge werden aus der Bestellung gelöscht
    Und die Gegenstände sind wieder zur Ausleihe verfügbar
    Und ich befinde mich wieder auf der Startseite

  @personas
  Szenario: Bestellübersicht Bestellen
    Wenn ich einen Zweck eingebe
    Und ich die Bestellung abschliesse
    Dann ändert sich der Status der Bestellung auf Abgeschickt
    Und ich erhalte eine Bestellbestätigung
    Und in der Bestellbestätigung wird mitgeteilt, dass die Bestellung in Kürze bearbeitet wird
    Und ich befinde mich wieder auf der Startseite

  @personas
  Szenario: Bestellübersicht Zweck nicht eingegeben
    Wenn der Zweck nicht abgefüllt wird
    Dann hat der Benutzer keine Möglichkeit die Bestellung abzuschicken
