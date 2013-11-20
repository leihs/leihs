# language: de

Funktionalität: Modell

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenariogrundriss: Modelllöschversuch verhindern
    Angenommen das Modell hat <Zuweisung> zugewiesen
    Dann kann ich das Modell aus der Liste nicht löschen

  Beispiele:
    | Zuweisung   |
    | Vertrag     |
    | Bestellung  |
    | Gegenstand  |

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
