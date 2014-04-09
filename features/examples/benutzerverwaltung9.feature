# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Benutzer den Zugriff auf ein Inventarpool reaktivieren
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der mal einen Zugriff auf das aktuelle Inventarpool hatte
    Wenn man den Zugriff auf "Kunde" ändert
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und hat der Benutzer die Rolle Kunde

  @javascript
  Szenario: Benutzer als Administrator löschen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann wurde der Benutzer aus der Liste gelöscht
    Und der Benutzer ist gelöscht

  Szenario: Startseite zurücksetzen
    Angenommen man ist "Pius"
    Und man hat eine Startseite gesetzt
    Wenn man seine Startseite zurücksetzt
    Dann ist ist keine Startseite gesetzt
    Wenn man auf das Logo klickt
    Dann landet man auf der Tagesansicht als Standard-Startseite
