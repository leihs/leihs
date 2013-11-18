# language: de

Funktionalität: Gerätepark-Grundinformationen

  Um die Grundinformationen meines Gerätepark zu verwalten
  möchte ich als Zuständiger
  die Informationen/Einstellungen für einen Gerätepark bearbeiten können
  
  @javascript
  Szenario: Arbeitstage verwalten
   Angenommen Personas existieren
   Und ich bin Mike
   Und ich verwalte die Gerätepark Grundinformationen
   Wenn ich die Arbeitstage Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, Sonntag ändere
   Und ich speichere
   Dann sind die Arbeitstage gespeichert

  @javascript
  Szenario: Tage der Ausleihschliessung verwalten
   Angenommen Personas existieren
   Und ich bin Mike
   Und ich verwalte die Gerätepark Grundinformationen
   Wenn ich eine oder mehrere Zeitspannen und einen Namen für die Ausleihsschliessung angebe
   Und ich speichere
   Dann werden die Ausleihschliessungszeiten gespeichert
   Und ich kann die Ausleihschliessungszeiten wieder löschen  
