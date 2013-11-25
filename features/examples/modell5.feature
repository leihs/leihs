# language: de

Funktionalität: Modell

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Modelldetails bearbeiten
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein bestehendes, genutztes Modell bearbeite
    Und ich ändere die folgenden Details
    | Feld                               | Wert                         |
    | Name                               | Test Modell x                |
    | Hersteller                         | Test Hersteller x            |
    | Beschreibung                       | Test Beschreibung x          |
    | Technische Details                 | Test Technische Details x    |
    | Interne Beschreibung               | Test Interne Beschreibung x  |
    | Wichtige Notizen zur Aushändigung  | Test Notizen x               |
    Und ich speichere die Informationen
    Und die Informationen sind gespeichert
    Und die Daten wurden entsprechend aktualisiert

  @javascript
  Szenario: Attachments erstellen
    Und ich erstelle ein neues Modell oder ich ändere ein bestehendes Modell
    Dann füge ich eine oder mehrere Datein den Attachments hinzu
    Und kann Attachments auch wieder entfernen
    Und ich speichere die Informationen
    Dann sind die Attachments gespeichert

  @javascript
  Szenario: Modelanhängsel löschen
    Angenommen es existiert ein Modell mit folgenden Eigenschaften
      | in keinem Vertrag aufgeführt |
      | keiner Bestellung zugewiesen |
      | keine Gegenstände zugefügt |
      | hat Gruppenkapazitäten zugeteilt |
      | hat Eigenschaften |
      | hat Zubehör |
      | hat Bilder |
      | hat Anhänge |
      | hat Kategoriezuweisungen |
      | hat sich ergänzende Modelle |
    Wenn ich dieses Modell aus der Liste lösche
    Und das Modell ist gelöscht
    Und es wurden auch alle Anhängsel gelöscht
