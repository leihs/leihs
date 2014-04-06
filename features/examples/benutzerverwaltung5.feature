# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Zugriff auf Ausleihe-Verwalter ändern als Ausleihe-Verwalter
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer der Kunde ist
    Dann man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
    Wenn man den Zugriff auf "Ausleihe-Verwalter" ändert
    Und ich speichere
    Dann hat der Benutzer die Rolle Ausleihe-Verwalter

  @javascript
  Szenario: Zugriff auf Kunde ändern als Ausleihe-Verwalter
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer der Ausleihe-Verwalter ist
    Wenn man den Zugriff auf "Kunde" ändert
    Und ich speichere
    Dann hat der Benutzer die Rolle Kunde

  @javascript
  Szenario: Zugriff ändern als Inventar-Verwalter
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der Kunde ist
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
  Szenario: Zugriff auf ein Inventarpool gewährleisten als Inventar-Verwalter
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der kein Zugriff auf das aktuelle Inventarpool hat
    Wenn man den Zugriff auf "Kunde" ändert
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und hat der Benutzer die Rolle Kunde
