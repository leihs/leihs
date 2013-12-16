# language: de

Funktionalität: Gegenstand erstellen

  @javascript
  Szenario: Wo man einen Gegenstand erstellen kann
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man befindet sich auf der Liste des Inventars
    Dann kann man einen Gegenstand erstellen

  @javascript
  Szenario: Felder die bereits vorausgefüllt sind
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandserstellungsseite
    Dann ist der Barcode bereits gesetzt
    Und Letzte Inventur ist das heutige Datum
    Und folgende Felder haben folgende Standardwerte
    | Feldname         | Type             | Wert             |
    | Ausleihbar       | radio            | Nicht ausleihbar |
    | Inventarrelevant | select           | Ja               |
    | Zustand          | radio            | OK               |
    | Vollständigkeit  | radio            | OK               |
    | Anschaffungskategorie  | select     |                  |    
    
  @javascript
  Szenario: Werte für Anschaffungskategorie hinterlegen
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandserstellungsseite
    Dann sind die folgenden Werte im Feld Anschaffungskategorie hinterlegt
    | Anschaffungskategorie |
    | Werkstatt-Technik     |
    | Produktionstechnik    |
    | AV-Technik            |
    | Musikinstrumente      |
    | Facility Management   |
    | IC-Technik/Software   |
