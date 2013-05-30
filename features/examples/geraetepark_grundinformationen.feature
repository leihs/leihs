# language: de

Funktionalität: Gerätepark-Grundinformationen

  Um die Grundinformationen meines Gerätepark zu verwalten
  möchte ich als Zuständiger
  die Informationen/Einstellungen für einen Gerätepark bearbeiten können

  #Grundlage:
    #Angenommen Personas existieren

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
    Dann sind die Informationen aktualisiert
    Und ich bleibe auf derselben Ansicht 
    Und sehe eine Bestätigung

  @javascript
  Szenariogrundriss: Pflichtfelder der Grundinformationen einzeln prüfen
    Angenommen Personas existieren
    Und ich bin Mike
    Wenn ich die Grundinformationen des Geräteparks abfüllen möchte
    Und jedes Pflichtfeld ist gesetzt
    | Name        |
    | Kurzname    |
    | E-Mail      |
    Wenn ich das gekennzeichnete <Pflichtfeld> leer lasse
    Dann kann das Gerätepark nicht gespeichert werden
    Und ich sehe eine Fehlermeldung
    Und die anderen Angaben wurde nicht gelöscht

    Beispiele:
      | Pflichtfeld |
      | Name        |
      | Kurzname    |
      | E-Mail      |

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

  @javascript
  Szenario: Arbeitstage verwalten
   Angenommen Personas existieren
   Und ich bin Mike
   Und ich verwalte die Gerätepark Grundinformationen
   Wenn ich die Arbeitstage Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, Sonntag ändere
   Und ich die Änderungen speichere
   Dann sind die Arbeitstage gespeichert

  @javascript
  Szenario: Tage der Ausleihschliessung verwalten
   Angenommen Personas existieren
   Und ich bin Mike
   Und ich verwalte die Gerätepark Grundinformationen
   Wenn ich eine oder mehrere Zeitspannen und einen Namen für die Ausleihsschliessung angebe
   Und ich speichere den Gerätepark
   Dann werden die Ausleihschliessungszeiten gespeichert
   Und ich kann die Ausleihschliessungszeiten wieder löschen  
