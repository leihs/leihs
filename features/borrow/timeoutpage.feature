# language: de

Funktionalität: Timeout Page

  Szenario: Bestellung abgelaufen
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Und ich habe Gegenstände der Bestellung hinzugefügt
    Und die letzte Aktivität auf meiner Bestellung ist mehr als 30 minuten her
    Wenn ich die Seite der Hauptkategorien besuche
    Dann lande ich auf der Bestellung-Abgelaufen-Seite
    Und ich sehe eine Information, dass die Geräte nicht mehr reserviert sind

  Szenario: Ansicht
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Dann sehe ich meine Bestellung
    Und die nicht mehr verfügbaren Modelle sind hervorgehoben
    Und ich kann Einträge löschen
    Und ich kann Einträge editieren
    Und ich kann zur Hauptübersicht
  
  @javascript
  Szenario: Eintrag löschen
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Und ich lösche einen Eintrag
    Dann wird der Eintrag aus der Bestellung gelöscht

  @javascript
  Szenario: Eintrag ändern
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Und ich einen Eintrag ändere
    Dann werden die Änderungen gespeichert
    Und lande ich wieder auf der Timeout Page

  @javascript
  Szenario: Die Menge eines Eintrags heruntersetzen
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Wenn ich die Menge eines Eintrags heraufsetze
    Dann werden die Änderungen gespeichert
    Wenn ich die Menge eines Eintrags heruntersetze
    Dann werden die Änderungen gespeichert
    Und lande ich wieder auf der Timeout Page
