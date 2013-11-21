# language: de

Funktionalität: Modell mit Paketen erstellen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Modell mit Paketzuteilung erstellen und wieder editieren
    Wenn ich ein neues Modell hinzufüge
    Und ich mindestens die Pflichtfelder ausfülle
    Und ich eine Paket hinzufüge
    Und ich die Paketeigenschaften eintrage
    Und ich diesem Paket eines oder mehrere Gegenstände hinzufügen
    Und ich dieses Paket speichere
    Und ich dieses Paket wieder editiere
    Dann kann ich die Paketeigenschaften erneut bearbeiten
    Und ich kann diesem Paket eines oder mehrere Gegenstände hinzufügen
