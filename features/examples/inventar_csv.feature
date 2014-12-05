# language: de

Funktionalität: Inventar

  @personas
  Szenario: Globaler Export des Inventars aller Geräteparks
    Angenommen ich bin Gino
    Und man öffnet die Liste der Geräteparks
    Dann kann man das globale Inventar als CSV-Datei exportieren

  @javascript @personas @browser
  Szenario: Export der aktuellen Ansicht als CSV
    Angenommen ich bin Mike
    Und man öffnet die Liste des Inventars
    Wenn ich den Reiter "Modelle" einsehe
    Dann kann man diese Daten als CSV-Datei exportieren
    Und die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden (inkl. Filter)
    Und die Zeilen enthalten die folgenden Felder in aufgeführter Reihenfolge
    | Felder                            |
    | Erstellt am                       |
    | Aktualisiert am                   |
    | Produkt                           |
    | Version                           |
    | Hersteller                        |
    | Beschreibung                      |
    | Technische Details                |
    | Interne Beschreibung              |
    | Wichtige Notizen zur Aushändigung |
    | Kategorien                        |
    | Zubehör                           |
    | Ergänzende Modelle                |
    | Eigenschaften                     |
    | Inventarcode                      |
    | Seriennummer                      |
    | MAC-Adresse                       |
    | IMEI-Nummer                       |
    | Name                              |
    | Notiz                             |
    | Ausmusterung                      |
    | Grund der Ausmusterung            |
    | Zustand                           |
    | Vollständigkeit                   |
    | Ausleihbar                        |
    | Gebäude                           |
    | Raum                              |
    | Gestell                           |
    | Inventarrelevant                  |
    | Besitzer                          |
    | Letzte Inventur                   |
    | Verantwortliche Abteilung         |
    | Verantwortliche Person            |
    | Benutzer/Verwendung               |
    | Anschaffungskategorie             |
    | Bezug                             |
    | Projektnummer                     |
    | Rechnungsnummer                   |
    | Rechnungsdatum                    |
    | Anschaffungswert                  |
    | Lieferant                         |
    | Garantieablaufdatum               |
    | Vertragsablaufdatum               |
    | Umzug                             |
    | Zielraum                          |
    | Ankunftsdatum                     |
    | Ankunftszustand                   |
    | Ankunftsnotiz                     |
    Wenn ich den Reiter "Software" einsehe
    Dann kann man diese Daten als CSV-Datei exportieren
    Und die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden (inkl. Filter)
    Und die Zeilen enthalten die folgenden Felder in aufgeführter Reihenfolge
    | Felder                            |
    | Erstellt am                       |
    | Aktualisiert am                   |
    | Produkt                           |
    | Version                           |
    | Hersteller                        |
    | Software Informationen            |
    | Inventarcode                      |
    | Seriennummer                      |
    | Notiz                             |
    | Aktivierungstyp                   |
    | Dongle ID                         |
    | Lizenztyp                         |
    | Gesamtanzahl                      |
    | Anzahl-Zuteilungen                |
    | Betriebssystem                    |
    | Installation                      |
    | Lizenzablaufdatum                 |
    | Ausmusterung                      |
    | Grund der Ausmusterung            |
    | Ausleihbar                        |
    | Besitzer                          |
    | Verantwortliche Abteilung         |
    | Bezug                             |
    | Projektnummer                     |
    | Rechnungsdatum                    |
    | Anschaffungswert                  |
    | Lieferant                         |
    | Beschafft durch                   |
    | Maintenance-Vertrag               |
    | Maintenance-Ablaufdatum           |
    | Währung                           |
    | Preis                             |
