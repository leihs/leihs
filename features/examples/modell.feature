# language: de

Funktionalität: Modell

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Übersicht neues Modell hinzufügen
  Wenn ich ein neues Modell hinzufüge
  Dann habe ich die Möglichkeit, folgende Informationen zu erfassen:
    | Details      |
    | Bilder       |
    | Anhänge      |
    | Zubehör      |

  @javascript
  Szenario: Modelldetails abfüllen
    Wenn ich ein neues Modell hinzufüge
    Und ich erfasse die folgenden Details
    | Feld                               | Wert                       |
    | Name                               | Test Modell                |
    | Hersteller                         | Test Hersteller            |
    | Beschreibung                       | Test Beschreibung          |
    | Technische Details                 | Test Technische Details    |
    | Interne Beschreibung               | Test Interne Beschreibung  |
    | Wichtige Notizen zur Aushändigung  | Test Notizen               |
    Und ich speichere die Informationen
    Dann das neue Modell ist erstellt

  @javascript
  Szenario: Modell erstellen nur mit Name
    Wenn ich ein neues Modell hinzufüge
    Und ich speichere die Informationen
    Dann wird das Modell nicht gespeichert, da es keinen Namen hat
    Und sehe ich eine Fehlermeldung
    Wenn ich einen Namen eines existierenden Modelles eingebe
    Und ich speichere die Informationen
    Dann wird das Modell nicht gespeichert, da es keinen eindeutigen Namen hat
    Und ich sehe eine Fehlermeldung
    Wenn ich die folgenden Details ändere
    | Feld                               | Wert                         |
    | Name                               | Test Modell y                |
    Und ich speichere die Informationen
    Dann das neue Modell ist erstellt

  @javascript
  Szenario: Modelldetails bearbeiten
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein bestehendes Modell bearbeite
    Und ich ändere die folgenden Details
    | Feld                               | Wert                         |
    | Name                               | Test Modell x                |
    | Hersteller                         | Test Hersteller x            |
    | Beschreibung                       | Test Beschreibung x          |
    | Technische Details                 | Test Technische Details x    |
    | Interne Beschreibung               | Test Interne Beschreibung x  |
    | Wichtige Notizen zur Aushändigung  | Test Notizen x               |
    Und ich speichere die Informationen
    Und die Informationen sind gespeichert
    Und die Daten wurden entsprechend aktualisiert

  @javascript
  Szenario: Modellzubehör bearbeiten
    Wenn ich ein bestehendes Modell bearbeite welches bereits Zubehör hat
    Dann ich sehe das gesamte Zubehöre für dieses Modell
    Und ich sehe, welches Zubehör für meinen Pool aktiviert ist
    Wenn ich Zubehör hinzufüge und falls notwendig die Anzahl des Zubehör ins Textfeld schreibe
    Und ich speichere die Informationen
    Dann ist das Zubehör dem Modell hinzugefügt worden
  
  @javascript
  Szenario: Modellzubehör löschen
    Wenn ich ein bestehendes Modell bearbeite welches bereits Zubehör hat
    Dann kann ich ein einzelnes Zubehör löschen, wenn es für keinen anderen Pool aktiviert ist

  @javascript
  Szenario: Modellzubehör deaktivieren
    Wenn ich ein bestehendes Modell bearbeite welches bereits Zubehör hat
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
    Wenn ich ein bestehendes Modell bearbeite
    Dann kann ich mehrere Bilder hinzufügen
    Und ich kann Bilder auch wieder entfernen
    Und ich speichere das Modell mit Bilder
    Dann wurden die ausgewählten Bilder für dieses Modell gespeichert
    Und zu grosse Bilder werden den erlaubten Grössen entsprechend verkleinert
    
  @javascript
  Szenario: sich ergänzende Modelle hinzufügen (kompatibel)
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein bestehendes Modell bearbeite
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

  @javascript
  Szenario: sich ergänzende Modelle entfernen (kompatibel)
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein Modell öffne, das bereits ergänzende Modelle hat
    Und ich ein ergänzendes Modell entferne
    Und ich speichere die Informationen
    Dann ist das Modell ohne das gelöschte ergänzende Modell gespeichert

  @javascript
  Szenario: Gruppenverteilung editieren
    Angenommen ich editieren ein bestehndes Modell mit bereits zugeteilten Kapazitäten
    Wenn ich bestehende Zuteilungen entfernen
    Und neue Zuteilungen hinzufügen
    Und ich speichere die Informationen
    Dann sind die geänderten Gruppenzuteilungen gespeichert

  @javascript
  Szenario: Modell löschen
    Angenommen es existiert ein Modell mit folgenden Eigenschaften
      | in keinem Vertrag aufgeführt |
      | keiner Bestellung zugewiesen |
      | keine Gegenstände zugefügt |
    Wenn ich dieses Modell aus der Liste lösche
    Und das Modell wurde aus der Liste gelöscht
    Und das Modell ist gelöscht

  @javascript
  Szenariogrundriss: Modelllöschversuch verhindern
    Angenommen das Modell hat <Zuweisung> zugewiesen
    Dann kann ich das Modell aus der Liste nicht löschen

  Beispiele:
    | Zuweisung   |
    | Vertrag     |
    | Bestellung  |
    | Gegenstand  |

  @javascript
  Szenario: Modelanhängsel löschen
    Angenommen es existiert ein Modell mit folgenden Eigenschaften
      | in keinem Vertrag aufgeführt |
      | keiner Bestellung zugewiesen |
      | keine Gegenstände zugefügt |
      | hat Gruppenkapazitäten zugeteilt |
      | hat Eigenschaften |
      | hat Zubehör |
      | hat Bilder |
      | hat Anhänge |
      | hat Kategoriezuweisungen |
      | hat sich ergänzende Modelle |
    Wenn ich dieses Modell aus der Liste lösche
    Und das Modell ist gelöscht
    Und es wurden auch alle Anhängsel gelöscht
