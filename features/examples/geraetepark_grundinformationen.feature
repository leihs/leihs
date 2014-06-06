# language: de

Funktionalität: Gerätepark-Grundinformationen

  Um die Grundinformationen meines Gerätepark zu verwalten
  möchte ich als Zuständiger
  die Informationen/Einstellungen für einen Gerätepark bearbeiten können

  @javascript @personas
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
    | Automatischer Zugriff |
    Und ich kann die angegebenen Grundinformationen speichern
    Dann sehe eine Bestätigung
    Und sind die Informationen aktualisiert
    Und ich bleibe auf derselben Ansicht

  @personas
  Szenario: Pflichtfelder der Grundinformationen zusammen prüfen
    Angenommen ich bin Mike
    Und ich die Grundinformationen des Geräteparks abfüllen möchte
    Und ich die folgenden Felder nicht befüllt habe
      | Name     |
      | Kurzname |
      | E-Mail   |
    Dann kann das Gerätepark nicht gespeichert werden
    Und ich sehe eine Fehlermeldung

  @personas
  Szenario: Aut. zuweisen beim Benutzererstellen ausserhalb des Geräteparks
    Angenommen ich bin Gino
    Und es ist bei mehreren Geräteparks aut. Zuweisung aktiviert
    Und man befindet sich auf der Benutzerliste
    Wenn ich einen Benutzer mit Login "username" und Passwort "password" erstellt habe
    Dann kriegt der neu erstellte Benutzer bei allen Geräteparks mit aut. Zuweisung die Rolle 'Kunde'

  @personas
  Szenario: Aut. zuweisen beim Benutzererstellen innerhalb des Geräteparks
    Angenommen ich bin Mike
    Und es ist bei mehreren Geräteparks aut. Zuweisung aktiviert
    Und es ist bei meinem Gerätepark aut. Zuweisung aktiviert
    Wenn ich in meinem Gerätepark einen neuen Benutzer mit Rolle 'Inventar-Verwalter' erstelle
    Dann kriegt der neu erstellte Benutzer bei allen Geräteparks mit aut. Zuweisung ausser meinem die Rolle 'Kunde'
    Und in meinem Gerätepark hat er die Rolle 'Inventar-Verwalter'

  @personas
  Szenario: Aut. Zuweisen entfernen
    Angenommen ich bin Mike
    Und ich editiere meinen Gerätepark
    Wenn ich die aut. Zuweisung deaktiviere
    Und ich speichere
    Dann ist die aut. Zuweisung deaktiviert
    Angenommen ich bin Gino
    Und man befindet sich auf der Benutzerliste
    Und ich einen Benutzer mit Login "username" und Passwort "password" erstellt habe
    Angenommen ich bin Mike
    Dann kriegt der neu erstellte Benutzer bei dem vorher editierten Gerätepark kein Zugriffsrecht
    Und ich logge mich aus

  @personas
  Szenario: Arbeitstage verwalten
   Angenommen ich bin Mike
   Und ich verwalte die Gerätepark Grundinformationen
   Wenn ich die Arbeitstage Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, Sonntag ändere
   Und ich speichere
   Dann sind die Arbeitstage gespeichert

  @javascript @personas
  Szenario: Tage der Ausleihschliessung verwalten
   Angenommen ich bin Mike
   Und ich verwalte die Gerätepark Grundinformationen
   Wenn ich eine oder mehrere Zeitspannen und einen Namen für die Ausleihsschliessung angebe
   Und ich speichere
   Dann werden die Ausleihschliessungszeiten gespeichert
   Und ich kann die Ausleihschliessungszeiten wieder löschen

  @personas
  Szenariogrundriss: Pflichtfelder der Grundinformationen einzeln prüfen
    Angenommen ich bin Mike
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

  @personas
  Szenario: Automatische Benutzersperrung bei verspäteter Rückgabe
    Angenommen ich bin Mike
    Wenn ich die Grundinformationen des Geräteparks abfüllen möchte
    Wenn ich für den Gerätepark die automatische Sperrung von Benutzern mit verspäteten Rückgaben einschalte
    Dann muss ich einen Sperrgrund angeben
    Wenn ich speichere
    Dann ist diese Konfiguration gespeichert
    Wenn ein Benutzer wegen verspäteter Rückgaben automatisch gesperrt wird
    Dann wird er für diesen Gerätepark gesperrt bis zum '1.1.2099'
    Und der Sperrgrund ist derjenige, der für diesen Park gespeichert ist

  @personas
  Szenario: Automatische Benutzersperrung nur wenn Benutzer nicht schon gesperrt
    Angenommen ich bin Mike
    Wenn ich für den Gerätepark die automatische Sperrung von Benutzern mit verspäteter Rückgaben einschalte
    Und ein Benutzer bereits gesperrt ist
    Dann werden der bestehende Sperrgrund sowie die Sperrzeit dieses Benutzers nicht überschrieben

