# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"
    
  @javascript
  Szenario: Pflichtfelder
    Angenommen man editiert einen Gegenstand
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
    Angenommen man editiert einen Gegenstand
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
