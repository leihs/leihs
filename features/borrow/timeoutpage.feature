# language: de

Funktionalität: Timeout Page

  @personas
  Szenario: Bestellung abgelaufen
    Angenommen ich bin Normin
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Und ich habe Gegenstände der Bestellung hinzugefügt
    Und die letzte Aktivität auf meiner Bestellung ist mehr als 30 minuten her
    Wenn ich die Seite der Hauptkategorien besuche
    Dann lande ich auf der Bestellung-Abgelaufen-Seite
    Und ich sehe eine Information, dass die Geräte nicht mehr reserviert sind

  @personas
  Szenario: Ansicht
    Angenommen ich bin Normin
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Dann sehe ich meine Bestellung
    Und die nicht mehr verfügbaren Modelle sind hervorgehoben
    Und ich kann Einträge löschen
    Und ich kann Einträge editieren
    Und ich kann zur Hauptübersicht

  @javascript @browser @personas
  Szenario: Eintrag löschen
    Angenommen ich bin Normin
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Und ich lösche einen Eintrag
    Dann wird der Eintrag aus der Bestellung gelöscht

  @javascript @browser @personas
  Szenario: In Bestellung übernehmen nicht möglich
    Angenommen ich bin Normin
    Und ich zur Timeout Page mit 2 Konfliktmodellen weitergeleitet werde
    Wenn ich auf "Diese Bestellung fortsetzen" drücke
    Dann lande ich wieder auf der Timeout Page
    Und ich erhalte einen Fehler
    Wenn ich einen der Fehler korrigiere
    Und ich auf "Diese Bestellung fortsetzen" drücke
    Dann lande ich wieder auf der Timeout Page
    Und ich erhalte einen Fehler
    Wenn ich alle Fehler korrigiere
    Dann verschwindet die Fehlermeldung

  @personas
  Szenario: Bestellung löschen
    Angenommen ich bin Normin
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Wenn ich die Bestellung lösche
    Dann werden die Modelle meiner Bestellung freigegeben
    Und wird die Bestellung des Benutzers gelöscht
    Und ich lande auf der Seite der Hauptkategorien

  @personas
  Szenario: Nur verfügbare Modelle aus Bestellung übernehmen
    Angenommen ich bin Normin
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Wenn ein Modell nicht verfügbar ist
    Und ich auf "Mit den verfügbaren Modellen weiterfahren" drücke
    Dann werden die nicht verfügbaren Modelle aus der Bestellung gelöscht
    Und ich lande auf der Seite der Bestellübersicht
    Und ich sehe eine Information, dass alle Geräte wieder verfügbar sind

  @javascript @personas
  Szenario: Eintrag ändern
    Angenommen ich bin Normin
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Und ich einen Eintrag ändere
    Dann werden die Änderungen gespeichert
    Und lande ich wieder auf der Timeout Page

  @javascript @browser @personas
  Szenario: Die Menge eines Eintrags heruntersetzen
    Angenommen ich bin Normin
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Wenn ich die Menge eines Eintrags heraufsetze
    Dann werden die Änderungen gespeichert
    Wenn ich die Menge eines Eintrags heruntersetze
    Dann werden die Änderungen gespeichert
    Und lande ich wieder auf der Timeout Page
