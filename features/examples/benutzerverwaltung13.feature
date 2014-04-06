# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Voraussetzungen fürs Löschen eines Benutzers im Gerätepark
    Angenommen man ist "Ramon"
    Und man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus
    Und man befindet sich auf der Benutzerliste im beliebigen Inventarpool
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann sehe ich eine Fehlermeldung
    Und der Benutzer ist nicht gelöscht

  @javascript
  Szenario: Alphabetische Sortierung der Benutzer ausserhalb vom Inventarpool
    Angenommen man ist "Gino"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools

  @javascript
  Szenario: Zugriff entfernen als Ausleihe-Verwalter
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat
    Wenn man den Zugriff entfernt
    Und ich speichere
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool
