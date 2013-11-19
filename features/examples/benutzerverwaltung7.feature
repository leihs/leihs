# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Alphabetische Sortierung der Benutzer innerhalb vom Inventarpool
    Angenommen man ist "Gino"
    Und man befindet sich auf der Benutzerliste im beliebigen Inventarpool
    Dann sind die Benutzer nach ihrem Vornamen alphabetisch sortiert

  Szenario: Auflistung der Inventarpools eines Benutzers
    Angenommen man ist "Ramon"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man einen Benutzer mit Zugriffsrechten editiert
    Dann werden die ihm zugeteilt Geräteparks mit entsprechender Rolle aufgelistet

  @javascript
  Szenario: Benutzer ohne Zugriff im Inventarpool editieren ohne ihm dabei Zugriff zu gewährleisten
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer der kein Zugriff auf das aktuelle Inventarpool hat
    Wenn man ändert die Email
    Und man speichert den Benutzer
    Dann sieht man die Erfolgsbestätigung
    Und die neue Email des Benutzers wurde gespeichert
    Und der Benutzer hat nach wie vor keinen Zugriff auf das aktuelle Inventarpool
