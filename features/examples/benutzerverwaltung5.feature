# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Benutzer den Zugriff auf ein Inventarpool reaktivieren
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der mal einen Zugriff auf das aktuelle Inventarpool hatte
    Wenn man den Zugriff auf "Kunde" ändert
    Und man speichert den Benutzer
    Dann sieht man die Erfolgsbestätigung
    Und hat der Benutzer die Rolle Kunde

  Szenario: Startseite setzen
    Angenommen man ist "Pius"
    Und man befindet sich auf der Liste der Benutzer
    Wenn man die Startseite setzt
    Dann ist die Liste der Benutzer die Startseite

  Szenario: Startseite zurücksetzen
    Angenommen man ist "Pius"
    Und man hat eine Startseite gesetzt
    Wenn man seine Startseite zurücksetzt
    Dann ist ist keine Startseite gesetzt
    Wenn man auf das Logo klickt
    Dann landet man auf der Tagesansicht als Standard-Startseite

  @javascript
  Szenario: Zugriff auf Ausleihe-Verwalter ändern als Ausleihe-Verwalter
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer der Kunde ist
    Dann man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Lending manager    |
    Wenn man den Zugriff auf "Ausleihe-Verwalter" ändert
    Und man speichert den Benutzer
    Dann hat der Benutzer die Rolle Ausleihe-Verwalter

  @javascript
  Szenario: Zugriff auf Kunde ändern als Ausleihe-Verwalter
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer der Ausleihe-Verwalter ist
    Wenn man den Zugriff auf "Kunde" ändert
    Und man speichert den Benutzer
    Dann hat der Benutzer die Rolle Kunde

  @javascript
  Szenario: Zugriff ändern als Inventar-Verwalter
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der Kunde ist
    Dann man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Lending manager    |
      | Inventory manager  |
    Wenn man den Zugriff auf "Inventar-Verwalter" ändert
    Und man speichert den Benutzer
    Dann hat der Benutzer die Rolle Inventar-Verwalter

  @javascript
  Szenario: Zugriff auf ein Inventarpool gewährleisten als Inventar-Verwalter
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der kein Zugriff auf das aktuelle Inventarpool hat
    Wenn man den Zugriff auf "Kunde" ändert
    Und man speichert den Benutzer
    Dann sieht man die Erfolgsbestätigung
    Und hat der Benutzer die Rolle Kunde

  @javascript
  Szenario: Zugriff ändern als Administrator
    Angenommen man ist "Gino"
    Und man editiert in irgendeinem Inventarpool einen Benutzer der Kunde ist
    Dann man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Lending manager    |
      | Inventory manager  |
    Wenn man den Zugriff auf "Inventar-Verwalter" ändert
    Und man speichert den Benutzer
    Dann hat der Benutzer die Rolle Inventar-Verwalter

  @javascript
  Szenario: Zugriff entfernen als Ausleihe-Verwalter
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat
    Wenn man den Zugriff entfernt
    Und man speichert den Benutzer
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool
