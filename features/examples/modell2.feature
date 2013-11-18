# language: de

Funktionalität: Modell

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Modellzubehör bearbeiten
    Wenn ich ein bestehendes, genutztes Modell bearbeite welches bereits Zubehör hat
    Dann ich sehe das gesamte Zubehöre für dieses Modell
    Und ich sehe, welches Zubehör für meinen Pool aktiviert ist
    Wenn ich Zubehör hinzufüge und falls notwendig die Anzahl des Zubehör ins Textfeld schreibe
    Und ich speichere die Informationen
    Dann ist das Zubehör dem Modell hinzugefügt worden
  
  @javascript
  Szenario: Modellzubehör löschen
    Wenn ich ein bestehendes, genutztes Modell bearbeite welches bereits Zubehör hat
    Dann kann ich ein einzelnes Zubehör löschen, wenn es für keinen anderen Pool aktiviert ist

  @javascript
  Szenario: Modellzubehör deaktivieren
    Wenn ich ein bestehendes, genutztes Modell bearbeite welches bereits Zubehör hat
    Dann kann ich ein einzelnes Zubehör für meinen Pool deaktivieren

  @javascript
  Szenario: Attachments erstellen
    Und ich erstelle ein neues Modell oder ich ändere ein bestehendes Modell
    Dann füge ich eine oder mehrere Datein den Attachments hinzu
    Und kann Attachments auch wieder entfernen
    Und ich speichere die Informationen
    Dann sind die Attachments gespeichert

  @javascript
  Szenario: Bilder
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein bestehendes, genutztes Modell bearbeite
    Dann kann ich mehrere Bilder hinzufügen
    Und ich kann Bilder auch wieder entfernen
    Und ich speichere das Modell mit Bilder
    Dann wurden die ausgewählten Bilder für dieses Modell gespeichert
    Und zu grosse Bilder werden den erlaubten Grössen entsprechend verkleinert
    
  @javascript
  Szenario: sich ergänzende Modelle hinzufügen (kompatibel)
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein bestehendes, genutztes Modell bearbeite
    Und ich ein ergänzendes Modell mittel Autocomplete Feld hinzufüge
    Und ich speichere die Informationen
    Dann ist dem Modell das ergänzende Modell hinzugefügt worden

  @javascript
  Szenario: 2 Mal gleiches ergänzende Modelle hinzufügen (kompatibel)
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein Modell öffne, das bereits ergänzende Modelle hat
    Und ich ein bereits bestehendes ergänzende Modell mittel Autocomplete Feld hinzufüge
    Dann wurde das redundante Modell nicht hizugefügt
    Und ich speichere die Informationen
    Dann wurde das redundante ergänzende Modell nicht gespeichert
