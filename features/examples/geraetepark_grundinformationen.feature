# language: de

Funktionalität: Gerätepark-Grundinformationen

  Um die Grundinformationen meines Gerätepark zu verwalten
  möchte ich als Zuständiger
  die Informationen/Einstellungen für einen Gerätepark bearbeiten können

  @javascript
  Szenario: Grundinformationen erfassen
    Angenommen Personas existieren
    Und ich bin Mike
    Wenn ich den Admin-Bereich betrete
    Dann kann ich die Gerätepark-Grundinformationen eingeben
    | Name |
    | Kurzname |
    | E-Mail |
    | Beschreibung |
    | Standard-Vertragsnotiz |
    | Verträge drucken | 
    Und ich kann die angegebenen Grundinformationen speichern
    Dann sehe eine Bestätigung
    Und sind die Informationen aktualisiert
    Und ich bleibe auf derselben Ansicht 

  @javascript
  Szenario: Pflichtfelder der Grundinformationen zusammen prüfen
    Angenommen Personas existieren
    Und ich bin Mike
    Und ich die Grundinformationen des Geräteparks abfüllen möchte
    Und ich die folgenden Felder nicht befüllt habe
      | Name     |
      | Kurzname |
      | E-Mail   |
    Dann kann das Gerätepark nicht gespeichert werden
    Und ich sehe eine Fehlermeldung
