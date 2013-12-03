# language: de

Funktionalität: Gerätepark-Grundinformationen

  Um die Grundinformationen meines Gerätepark zu verwalten
  möchte ich als Zuständiger
  die Informationen/Einstellungen für einen Gerätepark bearbeiten können

  @javascript
  Szenariogrundriss: Pflichtfelder der Grundinformationen einzeln prüfen
    Angenommen Personas existieren
    Und ich bin Mike
    Wenn ich die Grundinformationen des Geräteparks abfüllen möchte
    Und jedes Pflichtfeld des Geräteparks ist gesetzt
    | Name        |
    | Kurzname    |
    | E-Mail      |
    Wenn ich das gekennzeichnete "<Pflichtfeld>" des Geräteparks leer lasse
    Dann kann das Gerätepark nicht gespeichert werden
    Und ich sehe eine Fehlermeldung
    Und die anderen Angaben wurde nicht gelöscht

    Beispiele:
      | Pflichtfeld |
      | Name        |
      | Kurzname    |
      | E-Mail      |
