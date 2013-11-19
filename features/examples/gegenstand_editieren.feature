# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man editiert einen Gegenstand, wo man der Besitzer ist

  @javascript
  Szenario: Pflichtfelder
    Dann muss der "Bezug" unter "Rechnungsinformationen" ausgewählt werden
    Wenn "Investition" bei "Bezug" ausgewählt ist muss auch "Projektnummer" angegeben werden
    Wenn "Ja" bei "Inventarrelevant" ausgewählt ist muss auch "Anschaffungskategorie" ausgewählt werden
    Wenn "Ja" bei "Ausmusterung" ausgewählt ist muss auch "Grund der Ausmusterung" angegeben werden
    Dann sind alle Pflichtfelder mit einem Stern gekenzeichnet
    Wenn ein Pflichtfeld nicht ausgefüllt/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern 
    Und der Benutzer sieht eine Fehlermeldung
    Und die nicht ausgefüllten/ausgewählten Pflichtfelder sind rot markiert

  @javascript
  Szenario: Reihenfolge der Felder
    Wenn I select "Ja" from "item[retired]"
    Wenn I choose "Investition"
    Dann sehe ich die Felder in folgender Reihenfolge:
    | Inventarcode |
    | Modell |
    | - Zustand - |
    | Ausmusterung |
    | Grund der Ausmusterung |
    | Zustand |
    | Vollständigkeit |
    | Ausleihbar |
    | - Inventar - |
    | Inventarrelevant |
    | Anschaffungskategorie |
    | Besitzer |
    | Letzte Inventur |
    | Verantwortliche Abteilung |
    | Verantwortliche Person |
    | Benutzer/Verwendung |
    | - Umzug - |
    | Umzug |
    | Zielraum |
    | - Toni Ankunftskontrolle - |
    | Ankunftsdatum |
    | Ankunftszustand |
    | Ankunftsnotiz |
    | - Allgemeine Informationen - |
    | Seriennummer |
    | MAC-Adresse |
    | IMEI-Nummer |
    | Name |
    | Notiz |
    | - Ort - |
    | Gebäude |
    | Raum |
    | Gestell |
    | - Rechnungsinformationen - |
    | Bezug |
    | Projektnummer |
    | Rechnungsnummer |
    | Rechnungsdatum |
    | Anschaffungswert |
    | Lieferant |
    | Garantieablaufdatum |
    | Vertragsablaufdatum |

  @javascript
  Szenario: Neuen Lieferanten erstellen falls nicht vorhanden
    Angenommen man navigiert zur Gegenstandsbearbeitungsseite
    Wenn ich einen nicht existierenen Lieferanten angebe
    Und ich speichern druecke
    Dann wird der neue Lieferant erstellt
    Und bei dem bearbeiteten Gegestand ist der neue Lieferant eingetragen

  @javascript
  Szenario: Lieferanten löschen
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes mit gesetztem Lieferanten
    Wenn ich den Lieferanten lösche
    Und ich speichern druecke
    Dann ist bei dem bearbeiteten Gegenstand keiner Lieferant eingetragen

