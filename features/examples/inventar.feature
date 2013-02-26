# language: de

Funktionalität: Inventar

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Was man auf einer Liste sieht
    Dann sieht man Modelle
    Und man sieht Optionen
    Und man sieht Pakete

  @javascript
  Szenario: Auswahlmöglichkeiten
    Dann hat man folgende Auswahlmöglichkeiten die nicht kombinierbar sind
    | auswahlmöglichkeit |
    | Alles              |
    | Ausgemustert       |
    | Ausleihbar         |
    | Nicht ausleihbar   |

  @javascript
  Szenario: Filtermöglichkeiten von Listen
    Dann hat man folgende Filtermöglichkeiten
    | filtermöglichkeit         |
    | An Lager                  |
    | Besitzer bin ich          |
    | Verantwortliche Abteilung |
    | Defekt                    |
    | Unvollständig             |
    Und die Filter können kombiniert werden

  @javascript
  Szenario: Grundeinstellung der Listenansicht
    Dann ist die Auswahl "Alles" aktiviert
    Und es sind keine Filtermöglichkeiten aktiviert
  
  @javascript
  Szenario: Aussehen einer Modell-Zeile
    Wenn man eine Modell-Zeile sieht
    Dann enthält die Modell-Zeile folgende Informationen:
    | information              |
    | Bild                     |
    | Name des Modells         |
    | Anzahl verfügbar (jetzt) |
    | Anzahl verfügbar (Total) |
  
  @javascript
  Szenario: Aussehen einer Gegenstands-Zeile
    Wenn der Gegenstand an Lager ist und meine Abteilung für den Gegenstand verantwortlich ist
    Dann enthält die Gegenstands-Zeile folgende Informationen:
    | information      |
    | Gebäudeabkürzung |
    | Raum             |
    | Gestell          |
    Wenn der Gegenstand nicht an Lager ist und meine Abteilung für den Gegenstand verantwortlich ist
    Dann enthält die Gegenstands-Zeile folgende Informationen:
    | information            |
    | Aktueller Ausleihender |
    | Enddatum der Ausleihe  |
    Wenn meine Abteilung Besitzer des Gegenstands ist die Verantwortung aber auf eine andere Abteilung abgetreten hat
    Dann enthält die Gegenstands-Zeile folgende Informationen:
    | information               |
    | Verantwortliche Abteilung |
    | Gebäudeabkürzung          |
    | Raum                      |

  @javascript
  Szenario: Aussehen einer Options-Zeile
    Dann enthält die Options-Zeile folgende Informationen
    | information |
    | Barcode     |
    | Name        |
    | Preis       |
  
  @javascript
  Szenario: Modell aufklappen
    Dann kann man jedes Modell aufklappen
    Und man sieht die Gegenstände, die zum Modell gehören
    Und so eine Zeile sieht aus wie eine Gegenstands-Zeile
  
  @javascript
  Szenario: Paket-Modelle aufklappen
    Dann kann man jedes Paket-Modell aufklappen
    Und man sieht die Pakete dieses Paket-Modells
    Und so eine Zeile sieht aus wie eine Gegenstands-Zeile
    Und man kann diese Paket-Zeile aufklappen
    Und man sieht die Bestandteile, die zum Paket gehören
    Und so eine Zeile zeigt nur noch Inventarcode und Modellname des Bestandteils

  @javascript
  Szenario: Export der aktuellen Ansicht als CSV
    Dann kann man diese Daten als CSV-Datei exportieren
    Und die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden (inkl. Filter)

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
    Wenn ich ein bestehendes Modell bearbeite
    Dann kann ich mehrere Bilder hinzufügen
    Und ich kann Bilder auch wieder entfernen
    Und ich speichere das Modell mit Bilder
    Dann wurden die ausgewählten Bilder für dieses Modell gespeichert
    Und zu grosse Bilder werden den erlaubten Grössen entsprechend verkleinert

  @javascript
  Szenario: Option hinzufügen
    Wenn ich eine neue Option hinzufüge
    Und ich ändere die folgenden Details
    | Feld        | Wert         |
    | Name        | Test Option  |
    | Preis       | 50           |
    | Barcode     | Test Barcode |
    Und ich speichere die Informationen
    Dann die neue Option ist erstellt

  @javascript
  Szenario: Option bearbeiten
    Wenn ich eine bestehende Option bearbeite
    Und ich erfasse die folgenden Details
    | Feld        | Wert           |
    | Name        | Test Option x  |
    | Preis       | 51             |
    | Barcode     | Test Barcode x |
    Und ich speichere die Informationen
    Dann die Informationen sind gespeichert
    Und die Daten wurden entsprechend aktualisiert
