# language: de

Funktionalität: Gerätepark-Grundinformationen

  Um die Grundinformationen meines Gerätepark zu verwalten
  möchte ich als Zuständiger
  die Informationen/Einstellungen für einen Gerätepark bearbeiten können

  Szenario: Grundinformationen erfassen
    Angenommen ich bin Mike
    Wenn ich den Admin-Bereich betrete
    Dann kann ich die Gerätepark-Grundinformationen eingeben
    | Name |
    | Kurzname |
    | E-Mail |
    | Beschreibung |
    | Standard-Vertragsnotiz |
    | Verträge drucken | 
    Und ich kann die angegebenen Grundinformationen speichern
    Dann sind die Informatoinen aktualisiert
    Und ich bleibe auf derselben Ansicht 
    Und sehe eine Bestätigung

  Szenario: Pflichtfelder der Grundinformationen prüfen
    Angenommen ich bin Mike
    Wenn ich die Grundinformationen des Geräteparks abfüllen möchte
    Und ich die Felder Name, Kurzname nicht befüllt habe
    Dann kann ich die Grundinformationen nicht speichern



