# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Zugriff ändern als Administrator
    Angenommen man ist "Gino"
    Und man editiert in irgendeinem Inventarpool einen Benutzer der Kunde ist
    Dann man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    Wenn man den Zugriff auf "Inventar-Verwalter" ändert
    Und ich speichere
    Dann hat der Benutzer die Rolle Inventar-Verwalter

  @javascript
  Szenario: Voraussetzungen fürs Löschen eines Benutzers
    Angenommen man ist "Ramon"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann sehe ich eine Fehlermeldung
    Und der Benutzer ist nicht gelöscht
