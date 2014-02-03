# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Sperrfunktion
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und man editiert einen Benutzer
    Und man nutzt die Sperrfunktion
    Dann muss man den Grund der Sperrung eingeben
    Und sofern der Benutzer gesperrt ist, kann man die Sperrung aufheben

  @javascript @upcoming
  Szenario: Elemente der Editieransicht
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und man editiert einen Benutzer
    Dann sieht man als Titel den Vornamen und Namen des Benutzers, sofern bereits vorhanden
    Dann sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:
    Dann sieht man die Sperrfunktion für diesen Benutzer
    Und sofern dieser Benutzer gesperrt ist, sieht man Grund und Dauer der Sperrung
    Dann sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:
    |en         |de           |
    |Last name  |Name         |
    |First name |Vorname      |
    |Address    |Strasse      |
    |Zip        |PLZ          |
    |City       |Ort          |
    |Country    |Land         |
    |Phone      |Telefonnummer|
    |E-Mail     |E-Mail-Adresse|
    Und man kann die Informationen ändern, sofern es sich um einen externen Benutzer handelt
    Und man kann die Informationen nicht verändern, sofern es sich um einen Benutzer handelt, der über ein externes Authentifizierungssystem eingerichtet wurde
    Und man sieht die Rollen des Benutzers und kann diese entsprechend seiner Rolle verändern
    Und man kann die vorgenommenen Änderungen abspeichern 
