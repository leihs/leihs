# language: de

Funktionalität: Option

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Option hinzufügen
    Wenn ich eine neue Option hinzufüge
    Und ich ändere die folgenden Details
    | Feld             | Wert         |
    | Produkt          | Test Option  |
    | Preis            | 50           |
    | Inventarcode     | Test Barcode |
    Und ich speichere die Informationen
    Dann die neue Option ist erstellt

  @javascript
  Szenario: Option bearbeiten
    Wenn ich eine bestehende Option bearbeite
    Und ich erfasse die folgenden Details
    | Feld             | Wert           |
    | Produkt          | Test Option x  |
    | Preis            | 51             |
    | Inventarcode     | Test Barcode x |
    Und ich speichere die Informationen
    Dann die Informationen sind gespeichert
    Und die Daten wurden entsprechend aktualisiert

