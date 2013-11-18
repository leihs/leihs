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
