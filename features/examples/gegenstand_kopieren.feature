# language: de

Funktionalität: Gegenstand kopieren

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"

  @javascript
  Szenario: Gegenstand erstellen und kopieren
    Angenommen man erstellt einen Gegenstand
    Wenn man speichert und kopiert
    Dann wird der Gegenstand gespeichert 
    Und eine neue Gegenstandserstellungsansicht wird geöffnet
    Und man sieht den Seitentitel 'Kopierten Gegenstand erstellen'
    Und man sieht den Abbrechen-Knopf
    Und die folgenden Felder wurden kopiert
    | Modell                       |
    | Ausmusterung                 |
    | Grund der Ausmusterung       |
    | Zustand                      |
    | Vollständigkeit              |
    | Ausleihbar                   |
    | Inventarrelevant             |
    | Besitzer                     |
    | Letzte Inventur              |
    | Verantwortliche Abteilung    |
    | Verantwortliche Person       |
    | Benutzer/Verwendung          |
    | Umzug                        |
    | Zielraum                     |
    | Ankunftsdatum                |
    | Ankunftszustand              |
    | Ankunftsnotiz                |
    | MAC-Adresse                  |
    | IMEI-Nummer                  |
    | Notiz                        |
    | Gebäude                      |
    | Raum                         |
    | Gestell                      |
    | Bezug                        |
    | Projektnummer                |
    | Rechnungsnummer              |
    | Rechnungsdatum               |
    | Anschaffungswert             |
    | Lieferant                    |
    | Garantieablaufdatum          |
    | Vertragsablaufdatum          |
    Und die folgenden Felder wurden nicht kopiert
    | Inventarcode                 |
    | Name                         |
    | Seriennummer                 |
    Und der Inventarcode ist vorausgefüllt
    Wenn man den kopierten Gegenstand speichert
    Dann wird der kopierte Gegenstand gespeichert
    Und man wird zur Liste des Inventars zurückgeführt

Szenario: Bestehenden Gegenstand aus Liste kopieren
    Angenommen man befindet sich in der Liste des Inventars
    Wenn man einen Gegenstand kopiert
    Dann wird eine neue Gegenstandserstellungsansicht geöffnet 
    Und alle Felder bis auf Inventarcode, Seriennummer und Name wurden kopiert

Szenario: Bestehenden Gegenstand aus Editieransicht kopieren
    Angenommen man befindet sich in der Gegenstandserstellungsansicht
    Wenn man einen Gegenstand speichert und kopiert
    Dann wird eine neue Gegenstandserstellungsansicht geöffnet 
    Und alle Felder bis auf Inventarcode, Seriennummer und Name wurden kopiert

