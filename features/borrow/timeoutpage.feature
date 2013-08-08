# language: de

Funktionalität: Timeout Page

  Grundlage:
    Angenommen man ist "Normin"
    Und ich zur Timeout Page weitergeleitet werde

  Szenario: Bestellung abgelaufen
    Angenommen man ist "Normin"
    Und ich habe Gegenstände der Bestellung hinzugefügt
    Und die letzte Aktivität auf meiner Bestellung ist mehr als 30 minuten her
    Wenn ich die Seite der Hauptkategorien besuche
    Dann lande ich auf der Bestellung-Abgelaufen-Seite
    Und ich sehe eine Information, dass die Geräte nicht mehr reserviert sind

  Szenario: Ansicht
    Dann sehe ich meine Bestellung
    Und die nicht mehr verfügbaren Modelle sind hervorgehoben
    Und ich kann Einträge löschen
    Und ich kann Einträge editieren
    Und ich kann zur Hauptübersicht
  
  Szenario: Eintrag löschen
    Und ich lösche einen Eintrag
    Dann wird der Eintrag aus der Bestellung gelöscht

  @javascript
  Szenario: Eintrag ändern
    Und ich einen Eintrag ändere
    Dann werden die Änderungen gespeichert
    Und lande ich wieder auf der Timeout Page

  @javascript
  Szenario: Die Menge eines Eintrags heruntersetzen
    Wenn ich die Menge eines Eintrags heraufsetze
    Dann werden die Änderungen gespeichert
    Wenn ich die Menge eines Eintrags heruntersetze
    Dann werden die Änderungen gespeichert
    Und lande ich wieder auf der Timeout Page

  Szenario: In Bestellung übernehmen nicht möglich
    Wenn ein Modell nicht verfügbar ist
    Und ich auf "Diese Bestellung fortsetzen" drücke
    Dann lande ich wieder auf der Timeout Page
    Und ich erhalte ich einen Fehler

  Szenario: Bestellung löschen
    Wenn ich die Bestellung lösche
    Dann werden die Modelle meiner Bestellung freigegeben
    Und wird die Bestellung des Benutzers gelöscht
    Und ich lande auf der Seite der Hauptkategorien

  Szenario: Nur verfügbare Modelle aus Bestellung übernehmen
    Wenn ein Modell nicht verfügbar ist
    Und ich auf "Mit den verfügbaren Modellen weiterfahren" drücke
    Dann werden die nicht verfügbaren Modelle aus der Bestellung gelöscht
    Und ich lande auf der Seite der Bestellübersicht
    Und ich sehe eine Information, dass alle Geräte wieder verfügbar sind
