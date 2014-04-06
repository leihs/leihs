# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Benutzer im Geräterpark als Administrator löschen
    Angenommen man ist "Gino"
    Und man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus
    Und man befindet sich auf der Benutzerliste im beliebigen Inventarpool
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann wurde der Benutzer aus der Liste gelöscht
    Und der Benutzer ist gelöscht

  @javascript
  Szenario: Zugriff entfernen als Administrator
    Angenommen man ist "Gino"
    Und man editiert einen Benutzer der Zugriff auf ein Inventarpool hat
    Wenn man den Zugriff entfernt
    Und ich speichere
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool

  Szenario: Startseite setzen
    Angenommen man ist "Pius"
    Und man befindet sich auf der Liste der Benutzer
    Wenn man die Startseite setzt
    Dann ist die Liste der Benutzer die Startseite
