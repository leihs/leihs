# language: de

Funktionalität: Gegenstand kopieren

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"

  @javascript
  Szenario: Gegenstand erstellen und kopieren
    Angenommen man erstellt einen Gegenstand
    | Feldname                     | Type         | Wert                          |
    | Modell                       | autocomplete | Sharp Beamer                  |
    | Ausmusterung                 | checkbox     | unchecked                     |
    | Zustand                      | radio        | OK                            |
    | Vollständigkeit              | radio        | OK                            |
    | Ausleihbar                   | radio        | OK                            |
    | Inventarrelevant             | select       | Ja                            |
    | Letzte Inventur              |              | 01.01.2013                    |
    | Verantwortliche Abteilung    | autocomplete | A-Ausleihe                    |
    | Verantwortliche Person       |              | Matus Kmit                    |
    | Benutzer/Verwendung          |              | Test Verwendung               |
    | Umzug                        | select       | sofort entsorgen              |
    | Zielraum                     |              | Test Raum                     |
    | Ankunftsdatum                |              | 01.01.2013                    |
    | Ankunftszustand              | select       | transportschaden              |
    | Ankunftsnotiz                |              | Test Notiz                    |
    | Seriennummer                 |              | Test Seriennummer             |
    | MAC-Adresse                  |              | Test MAC-Adresse              |
    | IMEI-Nummer                  |              | Test IMEI-Nummer              |
    | Name                         |              | Test Name                     |
    | Notiz                        |              | Test Notiz                    |
    | Gebäude                      | autocomplete | Keine/r                       |
    | Raum                         |              | Test Raum                     |
    | Gestell                      |              | Test Gestell                  |
    | Bezug                        | radio must   | investment                    |
    | Projektnummer                |              | Test Nummer                   |
    | Rechnungsnummer              |              | Test Nummer                   |
    | Rechnungsdatum               |              | 01.01.2013                    |
    | Anschaffungswert             |              | 50.0                          |
    #| Lieferant                    | autocomplete | Neuer Lieferant               |
    | Garantieablaufdatum          |              | 01.01.2013                    |
    | Vertragsablaufdatum          |              | 01.01.2013                    |
    Wenn man speichert und kopiert
    Dann wird der Gegenstand gespeichert
    Und eine neue Gegenstandserstellungsansicht wird geöffnet
    Und man sieht den Seitentitel 'Kopierten Gegenstand erstellen'
    Und man sieht den Abbrechen-Knopf
    Und alle Felder bis auf die folgenden wurden kopiert:
    | Inventarcode                 |
    | Name                         |
    | Seriennummer                 |
    Und der Inventarcode ist vorausgefüllt
    Wenn ich speichere
    Dann wird der kopierte Gegenstand gespeichert
    Und man wird zur Liste des Inventars zurückgeführt

  @javascript
  Szenario: Bestehenden Gegenstand aus Liste kopieren
    Angenommen man befindet sich auf der Liste des Inventars
    Wenn man einen Gegenstand kopiert
    Dann wird eine neue Gegenstandskopieransicht geöffnet
    Und alle Felder bis auf Inventarcode, Seriennummer und Name wurden kopiert

  @javascript
  Szenario: Bestehenden Gegenstand aus Editieransicht kopieren
    Angenommen man befindet sich auf der Gegenstandserstellungsansicht
    Wenn man speichert und kopiert
    Dann wird eine neue Gegenstandskopieransicht geöffnet
    Und alle Felder bis auf Inventarcode, Seriennummer und Name wurden kopiert

  @javascript
  Szenario: Gegenstand aus einem anderem Gerätepark kopieren
    Angenommen I go to logout
    Und man ist "Matti"
    Und man editiert ein Gegenstand eines anderen Besitzers
    Wenn man speichert und kopiert
    Dann wird eine neue Gegenstandskopieransicht geöffnet
    Und alle Felder sind editierbar, da man jetzt Besitzer von diesem Gegenstand ist

  @javascript
  Szenario: Neuen Lieferanten erstellen falls nicht vorhanden
    Angenommen man einen Gegenstand kopiert
    Dann wird eine neue Gegenstandskopieransicht geöffnet
    Wenn ich einen nicht existierenen Lieferanten angebe
    Und ich merke mir den Inventarcode für weitere Schritte
    Und ich speichern druecke
    Dann wird der neue Lieferant erstellt
    Und bei dem kopierten Gegestand ist der neue Lieferant eingetragen
