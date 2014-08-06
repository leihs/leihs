# language: de

Funktionalität: Inventar

  @personas
  Szenario: Globaler Export des Inventars aller Geräteparks
    Angenommen ich bin Gino
    Und man öffnet die Liste der Geräteparks
    Dann kann man das globale Inventar als CSV-Datei exportieren

  @javascript @personas @current
  Szenario: Export der aktuellen Ansicht als CSV
    Angenommen ich bin Mike
    Und man öffnet die Liste des Inventars
    Dann kann man diese Daten als CSV-Datei exportieren
    Und die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden (inkl. Filter)
    Und die Gegenstands und Optionszeilen enthalten die folgenden Felder in aufgeführter Reihenfolge
    | Felder                            |  
    | Erstellt am                       |  
    | Aktualisiert am                   |  
    | Modellname                        |  
    | Version                           |  
    | Hersteller                        |  
    | Beschreibung                      |  
    | Technische Details                |  
    | Interne Beschreibung              |  
    | Wichtige Notizen zur Aushändigung |  
    | Zuteilungen                       |  
    | Kategorien                        |  
    | Bildernamen                       |  
    | Anhangsnamen                      |  
    | Zubehör                           |  
    | Ergänzende Modelle                |  
    | Eigenschaften                     |  
    | Paketnummern                      |  
    | Inventarcode                      |  
    | Ausmusterung                      |  
    | Grund der Ausmusterung            |  
    | Zustand                           |  
    | Vollständigkeit                   |  
    | Ausleihbar                        |  
    | Inventarrelevant                  |  
    | Besitzer                          |  
    | Letzte Inventur                   |  
    | Verantwortliche Abteilung         |  
    | Benutzer/Verwendung               |  
    | Umzug                             |  
    | Zielraum                          |  
    | Ankunftsdatum                     |  
    | Ankunftszustand                   |  
    | Ankunftsnotiz                     |  
    | Seriennummer                      |  
    | MAC-Adresse                       |  
    | IMEI-Nummer                       |  
    | Name                              |  
    | Notiz                             |  
    | Gebäude                           |  
    | Raum                              |  
    | Gestell                           |  
    | Bezug                             |  
    | Rechnungsnummer                   |  
    | Rechnungsdatum                    |  
    | Anschaffungswert                  |  
    | Lieferant                         |  
    | Garantieablaufdatum               |  
    | Vertragsablaufdatum               |  
    Und die Software-Lizenzzeilen enthalten die folgenden Felder in aufgeführter Reihenfolge
    | Felder                            |  
    | Produktname                       |  
    | Version                           |  
    | Hersteller                        |  
    | Software Informationen            |  
    | Anhänge                           |  
    | Inventarcode                      |  
    | Ausmusterung                      |  
    | Ausleihbar                        |  
    | Besitzer                          |  
    | Verantwortliche Abteilung         |  
    | Bezug                             |  
    | Rechnungsdatum                    |  
    | Anschaffungswert                  |  
    | Lieferant                         |  
    | Beschafft durch                   |  
    | Seriennummer                      |  
    | Notiz                             |  
    | Aktivierungstyp                   |  
    | Dongle ID                         |  
    | Lizenztyp                         |  
    | Gesamtanzahl                      |  
    | Anzahl Zuteilungen                |  
    | Betriebssystem                    |  
    | Installation                      |  
    | Lizenzablaufdatum                 |  
    | Maintenance-Vertrag               |  
    | Maintenance-Ablaufdatum           |  
