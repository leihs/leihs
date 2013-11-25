# language: de

Funktionalität: Gegenstand erstellen

  @javascript
  Szenario: Felder beim Erstellen eines Gegenstandes
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandserstellungsseite
    Und I select "Ja" from "item[retired]"
    Und I choose "Investition"
    Dann sehe ich die Felder in folgender Reihenfolge:
    | Inventarcode                 |
    | Modell                       |
    | - Zustand -                  |
    | Ausmusterung                 |
    | Grund der Ausmusterung       |
    | Zustand                      |
    | Vollständigkeit              |
    | Ausleihbar                   |
    | - Inventar -                 |
    | Inventarrelevant             |
    | Anschaffungskategorie        |    
    | Besitzer                     |
    | Letzte Inventur              |
    | Verantwortliche Abteilung    |
    | Verantwortliche Person       |
    | Benutzer/Verwendung          |
    | - Umzug -                    |
    | Umzug                        |
    | Zielraum                     |
    | - Toni Ankunftskontrolle -   |
    | Ankunftsdatum                |
    | Ankunftszustand              |
    | Ankunftsnotiz                |
    | - Allgemeine Informationen - |
    | Seriennummer                 |
    | MAC-Adresse                  |
    | IMEI-Nummer                  |
    | Name                         |
    | Notiz                        |
    | - Ort -                      |
    | Gebäude                      |
    | Raum                         |
    | Gestell                      |
    | - Rechnungsinformationen -   |
    | Bezug                        |
    | Projektnummer                |
    | Rechnungsnummer              |
    | Rechnungsdatum               |
    | Anschaffungswert             |
    | Lieferant                    |
    | Garantieablaufdatum          |
    | Vertragsablaufdatum          |

  @javascript
  Szenario: Einen Gegenstand mit allen fehlenden Pflichtangaben erstellen
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandserstellungsseite
    Und man setzt Bezug auf Investition
    Und kein Pflichtfeld ist gesetzt
    | Modell        |
    | Inventarcode  |
    | Projektnummer |
    | Anschaffungskategorie  |
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung


