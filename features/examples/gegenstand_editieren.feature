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
    Wenn "Ausgemustert" bei "Ausmusterung" ausgewählt ist muss auch "Grund der Ausmusterung" angegeben werden
    Dann sind alle Pflichtfelder mit einem Stern gekenzeichnet
    Wenn ein Pflichtfeld nicht ausgefüllt/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern 
    Und der Benutzer sieht eine Fehlermeldung
    Und die nicht ausgefüllten/ausgewählten Pflichtfelder sind rot markiert

  @javascript
  Szenario: Reihenfolge der Felder
    Angenommen man editiert einen Gegenstand
    Dann sehe ich die Felder in der folgenden Reihenfolge:
    | Inventarcode |
    Allgemeine Informationen
    | Seriennummer |
    | MAC-Adresse |
    | IMEI-Nummer |
    | Name |
    | Notizen |
    Rechnungsinformationen
    | Bezug |
    | Projektnummer |
    | Rechnungsnummer |
    | Rechnungsdatum |
    | Anschaffungswert |
    | Versicherungsnummer |
    | Lieferant |
    | Gültigkeit Garantie |
    | Gültigkeit Supportvertrag |
    Inventar
    | Inventarrelevant |
    | Besitzer |
    | Letzte Inventur |
    | Verantwortliche Abteilung |
    | Verantwortliche Person |
    | Benutzer/Verwendung |
    Ort
    | Gebäude |
    | Raum |
    | Gestell |
    Zustand
    | Ausmusterung |
    | Grund der Ausmusterung |
    | Zustand |
    | Vollständigkeit |
    | Ausleihbar |
    Umzug
    | Umzug |
    | Zielraum |
    Toni Ankunftskontrolle
