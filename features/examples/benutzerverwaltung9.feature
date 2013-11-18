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

  @javascript
  Szenario: Zugriff entfernen als Administrator
    Angenommen man ist "Gino"
    Und man editiert einen Benutzer der Zugriff auf ein Inventarpool hat
    Wenn man den Zugriff entfernt
    Und man speichert den Benutzer
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool

  @javascript
  Szenario: Benutzer als Administrator löschen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann wurde der Benutzer aus der Liste gelöscht
    Und der Benutzer ist gelöscht

  @javascript
  Szenario: Benutzer im Geräterpark als Administrator löschen
    Angenommen man ist "Gino"
    Und man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus
    Und man befindet sich auf der Benutzerliste im beliebigen Inventarpool
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann wurde der Benutzer aus der Liste gelöscht
    Und der Benutzer ist gelöscht

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

