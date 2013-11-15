# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren


  @javascript
  Szenario: Zugriff entfernen als Inventar-Verwalter
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat und keine Gegenstände mehr zurückzugeben hat
    Wenn man den Zugriff entfernt
    Und man speichert den Benutzer
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool

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

  @javascript @upcoming
  Szenario: Gruppenzuteilung in Benutzeransicht hinzufügen/entfernen
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer
    Dann kann man Gruppen über eine Autocomplete-Liste hinzufügen
    Und kann Gruppen entfernen
    Und speichert den Benutzer
    Dann ist die Gruppenzugehörigkeit gespeichert 

  @javascript
  Szenario: Neuen Benutzer im Geräterpark als Inventar-Verwalter hinzufügen
    Angenommen man ist "Mike"
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | Adresse        |
      | PLZ            |
      | Ort            |
      | Land           |
      | Telefon        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access        |
      | Customer         |
      | Lending manager  |
      | Inventory manager  |
    Und eine der folgenden Rollen auswählt
    | tab                | role              |
    | Kunde              | customer          |
    | Ausleihe-Verwalter | lending_manager   |
    | Inventar-Verwalter | inventory_manager   |
    Und man teilt mehrere Gruppen zu
    Und man speichert den Benutzer
    Dann ist der Benutzer mit all den Informationen gespeichert
