# language: de

Funktionalität: Gegenstand erstellen

  @javascript
  Szenario: Wo man einen Gegenstand erstellen kann
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man befindet sich auf der Liste des Inventars
    Dann kann man einen Gegenstand erstellen

  @javascript
  Szenario: Neuen Lieferanten erstellen falls nicht vorhanden
    Angenommen ich bin Mike
    Und ich befinde mich auf der Erstellungsseite eines Gegenstandes
    Und jedes Pflichtfeld ist gesetzt
      | Modell        |
      | Inventarcode  |
      | Projektnummer |
      | Anschaffungskategorie |
    Wenn ich einen nicht existierenen Lieferanten angebe
    Und ich erstellen druecke
    Dann wird der neue Lieferant erstellt
    Und bei dem erstellten Gegestand ist der neue Lieferant eingetragen
