# language: de

Funktionalität: Gegenstand erstellen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"
    
  Szenario: Wo man einen Gegenstand erstellen kann
    Angenommen man befindet sich auf der Liste des Inventars
    Dann kann man einen Gegenstand erstellen

  Szenario: Felder beim Erstellen eines Gegenstandes
    Angenommen man navigiert zur Gegenstandserstellungsseite
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
    | Versicherungsnummer          |
    | Lieferant                    |
    | Garantieablaufdatum          |
    | Vertragsablaufdatum          |

  Szenario: Einen Gegenstand mit allen Informationen erstellen
    Angenommen man navigiert zur Gegenstandserstellungsseite
    Wenn ich alle Informationen erfasse, fuer die ich berechtigt bin
    Und ich erstellen druecke
    Dann ist der Gegenstand mit all den angegebenen Informationen erstellt
    Und man wird zur Liste des Inventars zurueckgefuehrt

  Szenario: Einen Gegenstand mit Mindestinformationen erstellen
    Angenommen man navigiert zur Gegenstandserstellungsseite
    Wenn ich weniger als die Informationen der gekennzeichneten Pflichtfelder eingebe
    | Modellname   |
    | Inventarcode |
    | Bezug        |
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung

  Szenario: Felder die bereits vorausgefüllt sind
    Angenommen man navigiert zur Gegenstandserstellungsseite
    Dann ist der Barcode bereits gesetzt
    Und folgende Felder haben folgende Standardwerte
    | Feld             | Standardwert     |
    | Ausleihbar       | nicht ausleihbar |
    | Zuletzt geprüft  | aktuellem Datum  |
    | Inventarrelevant | Ja               |
    | Zustand          | OK               |
    | Vollständigkeit  | OK               |
