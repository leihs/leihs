# language: de

Funktionalität: Modell mit Paketen erstellen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Paket löschen
    Wenn das Paket zurzeit nicht ausgeliehen ist 
    Dann kann ich das Paket löschen und die Gegenstände sind nicht mehr dem Paket zugeteilt

  @javascript
  Szenario: Paket löschen schlägt fehl wenn das Paket gerade ausgeliehen ist
    Wenn das Paket zurzeit ausgeliehen ist 
    Dann kann ich das Paket nicht löschen

  @javascript
  Szenario: Pakete nicht ohne Gegenstände erstellen
    Wenn ich einem Modell ein Paket hinzufüge
    Dann kann ich dieses Paket nur speichern, wenn dem Paket auch Gegenstände zugeteilt sind

  @javascript
  Szenario: Einzelnen Gegenstand aus Paket entfernen
    Wenn ich ein Paket editiere
    Dann kann ich einen Gegenstand aus dem Paket entfernen
    Und dieser Gegenstand ist nicht mehr dem Paket zugeteilt
