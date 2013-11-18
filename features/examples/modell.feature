# language: de

Funktionalität: Modell

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Übersicht neues Modell hinzufügen
  Wenn ich ein neues Modell hinzufüge
  Dann habe ich die Möglichkeit, folgende Informationen zu erfassen:
    | Details      |
    | Bilder       |
    | Anhänge      |
    | Zubehör      |

  @javascript
  Szenario: Modelldetails abfüllen
    Wenn ich ein neues Modell hinzufüge
    Und ich erfasse die folgenden Details
    | Feld                               | Wert                       |
    | Name                               | Test Modell                |
    | Hersteller                         | Test Hersteller            |
    | Beschreibung                       | Test Beschreibung          |
    | Technische Details                 | Test Technische Details    |
    | Interne Beschreibung               | Test Interne Beschreibung  |
    | Wichtige Notizen zur Aushändigung  | Test Notizen               |
    Und ich speichere die Informationen
    Dann ist das neue Modell erstellt und unter ungenutzen Modellen auffindbar

  @javascript
  Szenario: Modell erstellen nur mit Name
    Wenn ich ein neues Modell hinzufüge
    Und ich speichere die Informationen
    Dann wird das Modell nicht gespeichert, da es keinen Namen hat
    Und sehe ich eine Fehlermeldung
    Wenn ich einen Namen eines existierenden Modelles eingebe
    Und ich speichere die Informationen
    Dann wird das Modell nicht gespeichert, da es keinen eindeutigen Namen hat
    Und ich sehe eine Fehlermeldung
    Wenn ich die folgenden Details ändere
    | Feld                               | Wert                         |
    | Name                               | Test Modell y                |
    Und ich speichere die Informationen
    Dann ist das neue Modell erstellt und unter ungenutzen Modellen auffindbar
