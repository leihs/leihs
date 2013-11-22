# language: de

Funktionalität: Modell mit Paketen erstellen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Modell mit Paketzuteilung erstellen
    Wenn ich ein neues Modell hinzufüge
    Und ich mindestens die Pflichtfelder ausfülle
    Und ich eines oder mehrere Pakete hinzufüge
    Und ich diesem Paket eines oder mehrere Gegenstände hinzufügen
    Und ich das Paket und das Modell speichere
    Dann ist das Modell erstellt und die Pakete und dessen zugeteilten Gegenstände gespeichert
    Und den Paketen wird ein Inventarcode zugewiesen

  @javascript
  Szenario: Modell mit bereits vorhandenen Gegenständen kann kein Paket zugewiesen werden
    Wenn ich ein Modell editiere, welches bereits Gegenstände hat
    Dann kann ich diesem Modell keine Pakete mehr zuweisen
