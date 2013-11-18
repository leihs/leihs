# language: de

Funktionalität: Modell

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: sich ergänzende Modelle hinzufügen (kompatibel)
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein bestehendes, genutztes Modell bearbeite
    Und ich ein ergänzendes Modell mittel Autocomplete Feld hinzufüge
    Und ich speichere die Informationen
    Dann ist dem Modell das ergänzende Modell hinzugefügt worden

  @javascript
  Szenario: 2 Mal gleiches ergänzende Modelle hinzufügen (kompatibel)
    Angenommen man öffnet die Liste der Modelle
    Wenn ich ein Modell öffne, das bereits ergänzende Modelle hat
    Und ich ein bereits bestehendes ergänzende Modell mittel Autocomplete Feld hinzufüge
    Dann wurde das redundante Modell nicht hizugefügt
    Und ich speichere die Informationen
    Dann wurde das redundante ergänzende Modell nicht gespeichert

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
