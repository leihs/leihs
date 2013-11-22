# language: de

Funktionalität: Gegenstand erstellen

  @javascript
  Szenario: Einen Gegenstand mit einer fehlenden Pflichtangabe erstellen
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandserstellungsseite
    Und man setzt Bezug auf Investition
    Und jedes Pflichtfeld ist gesetzt
    | Modell        |
    | Inventarcode  |
    | Projektnummer |
    | Anschaffungskategorie |
    Wenn ich das gekennzeichnete "Projektnummer" leer lasse
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung
    Und die anderen Angaben wurde nicht gelöscht

  @javascript
  Szenario: Einen Gegenstand mit einer fehlenden Pflichtangabe erstellen
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandserstellungsseite
    Und man setzt Bezug auf Investition
    Und jedes Pflichtfeld ist gesetzt
    | Modell        |
    | Inventarcode  |
    | Projektnummer |
    | Anschaffungskategorie |
    Wenn ich das gekennzeichnete "Anschaffungskategorie" leer lasse
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung
    Und die anderen Angaben wurde nicht gelöscht
