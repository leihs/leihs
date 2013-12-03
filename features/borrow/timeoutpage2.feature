# language: de

Funktionalität: Timeout Page

  @javascript
  Szenario: In Bestellung übernehmen nicht möglich
    Angenommen man ist "Normin"
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

  Szenario: Bestellung löschen
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Wenn ich die Bestellung lösche
    Dann werden die Modelle meiner Bestellung freigegeben
    Und wird die Bestellung des Benutzers gelöscht
    Und ich lande auf der Seite der Hauptkategorien

  Szenario: Nur verfügbare Modelle aus Bestellung übernehmen
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Wenn ein Modell nicht verfügbar ist
    Und ich auf "Mit den verfügbaren Modellen weiterfahren" drücke
    Dann werden die nicht verfügbaren Modelle aus der Bestellung gelöscht
    Und ich lande auf der Seite der Bestellübersicht
    Und ich sehe eine Information, dass alle Geräte wieder verfügbar sind
