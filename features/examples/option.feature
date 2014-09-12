# language: de

Funktionalität: Option

  Grundlage:
    Angenommen ich bin Mike

  @javascript @browser @personas
  Szenario: Option hinzufügen
    Angenommen man öffnet die Liste des Inventars
    Wenn ich eine neue Option hinzufüge
    Und ich ändere die folgenden Details
    | Feld             | Wert         |
    | Produkt          | Test Option  |
    | Preis            | 50           |
    | Inventarcode     | Test Barcode |
    Und ich speichere die Informationen
    Dann die neue Option ist erstellt

  @javascript @browser @personas
  Szenario: Option bearbeiten
    Angenommen man öffnet die Liste des Inventars
    Wenn ich eine bestehende Option bearbeite
    Und ich erfasse die folgenden Details
    | Feld             | Wert           |
    | Produkt          | Test Option x  |
    | Preis            | 51             |
    | Inventarcode     | Test Barcode x |
    Und ich speichere die Informationen
    Dann die Informationen sind gespeichert
    Und die Daten wurden entsprechend aktualisiert

