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
  Szenario: Modell erstellen
    Dann habe ich in der Übersicht die Möglichkeit ein neues Modell zu erstellen
    Und erfasse die folgenden Details
    | Modellbezeichnung                  |
    | Hersteller                         |
    | Beschreibung                       |
    | Technische Details                 |
    | Interne Beschreibung               |
    | Wichtige Notizen zur Aushändigung  |
    Und ich speichere die Information
    Und ein neues Modell ist erstellt

  @javascript
  Szenario: Modell bearbeiten
    Dann habe ich in der Übersicht die Möglichkeit ein existierendes Modell zu ändern
    Und ich ändere die folgenden Details
    | Modellbezeichnung                  |
    | Hersteller                         |
    | Beschreibung                       |
    | Technische Details                 |
    | Interne Beschreibung               |
    | Wichtige Notizen zur Aushändigung  |
    Und ich speichere die Information
    Und die Informationen sind gespeichert

 @javascript
  Szenario: Zubehör erfassen
    Und ich erstelle ein neues Modell oder ich ändere ein bestehendes Modell
    Dann erfasse oder lösche ich eines oder mehrere Zubehöre
    Und beim Erfassen definiere ich dessen Anzahl

  @javascript
  Szenario: Attachments
    Und ich erstelle ein neues Modell oder ich ändere ein bestehendes Modell
    Dann füge ich eine Datei hinzu
    Und wähle ob diese Datei auch im Frontend oder nur im Backend sichtbar ist
    Und ich kann einen Alternativnamen für die Datei bestimmen
    Und kann Dateien auch wieder entfernen
    Und kann bereits bestehende Dateien herunterladen oder öffnen
    Und kann die Reihenfolge der Dateien bestimmen

  @javascript
  Szenario: Bilder
    Und ich erstelle ein neues Modell oder ich ändere ein bestehendes Modell
    Dann füge ich ein Bild hinzu
    Und wähle ob dieses auch im Frontend oder nur im Backend sichtbar ist
    Und kann Bilder auch wieder entfernen
    Und kann bereits bestehende Bilder herunterladen oder ansehen
    Und kann die Reihenfolge der Dateien bestimmen
    Und es wird verhindert, ein zu kleines Bild hochzuladen
    Und zu grosse Bilder werden den erlaubten Grössen entsprechend verkleinert
