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
    | Aut. zuweisen  |     
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
    
  @javascript
  Szenario: Aut. zuweisen bei Login über LDAP-Schnittstelle
    Angenommen Personas existieren
    Und es ist bei mehreren Geräteparks aut. Zuweisung aktiviert 
    Angenommen ich bin ein Benutzer, der sich zum ersten Mal einloggt
    Wenn ich mich einlogge
    Dann wird für meine Personendaten aus der Schnittstelle ein neuer Benutzer erstellt
    Und ich kriege bei allen Geräteparks mit aut. Zuweisung die Rolle 'Kunde'
    
  @javascript
  Szenario: Aut. zuweisen beim Benutzererstellen ausserhalb des Geräteparks
    Angenommen Personas existieren
    Und es ist bei mehreren Geräteparks aut. Zuweisung aktiviert 
    Angenommen ich bin Gino
    Und ich erstelle einen neuen Benutzer
    Dann kriegt der neu erstellte Benutzer bei allen Geräteparks mit aut. Zuweisung die Rolle 'Kunde'
    
  @javascript
  Szenario: Aut. zuweisen beim Benutzererstellen innerhalb des Geräteparks
    Angenommen Personas existieren
    Und es ist bei mehreren und meinem Gerätepark aut. Zuweisung aktiviert 
    Und ich bin Mike
    Wenn ich in meinem Gerätepark einen neuen Benutzer mit Rolle 'Inventar-Verwalter' erstelle 
    Dann kriegt der neu erstellte Benutzer bei allen Geräteparks mit aut. Zuweisung ausser meinem die Rolle 'Kunde'
    Und in meinem Gerätepark hat er die Rolle 'Inventar-Verwalter'
    
  @javascript
  Szenario: Aut. Zuweisen entfernen
    Angenommen Personas existieren
    Und ich bin Mike
    Und ich editiere meinen Gerätepark
    Wenn ich die aut. Zuweisung deaktiviere
    Und ich speichere
    Dann ist die aut. Zuweisung deaktiviert
    Angenommen ich bin ein Benutzer, der sich zum ersten Mal einloggt
    Dann erhalte ich keinen aut. Zugriff für diesen Gerätepark
