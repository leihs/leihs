# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  Szenario: Benutzerlevels aus leihs 2
    Angenommen ein Benutzer hat aus der leihs 2.0-Datenbank den Level 1 auf einem Gerätepark
    Dann gilt er in leihs 3.0 als Level 2 für diesen Gerätepark

  @javascript
  Szenario: Elemente der Benutzeradministration
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Dann findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"
    Dann sieht man eine Liste aller Benutzer
    Und man kann filtern nach den folgenden Eigenschaften: gesperrt
    Und man kann filtern nach den folgenden Rollen:
      | tab                | role               |
      | Kunde              | customers          |
      | Ausleihe-Verwalter | lending_managers   |
      | Inventar-Verwalter | inventory_managers |
    Und man kann für jeden Benutzer die Editieransicht aufrufen

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

  @javascript
  Szenario: Darstellung eines Benutzers in Listen mit zugeteilter Rolle
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Angenommen ein Benutzer mit zugeteilter Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
    |attr |
    |Vorname Name|
    |Telefonnummer|
    |Rolle|

  @javascript
  Szenario: Darstellung eines Benutzers in Listen ohne zugeteilte Rolle
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Angenommen ein Benutzer ohne zugeteilte Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
    |attr |
    |Vorname Name|
    |Telefonnummer|
    |Rolle|

  @javascript
  Szenario: Darstellung eines Benutzers in Listen mit zugeteilter Rolle und Status gesperrt
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Angenommen ein gesperrter Benutzer mit zugeteilter Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
    |attr |
    |Vorname Name|
    |Telefonnummer|
    |Rolle|
    |Sperr-Status 'Gesperrt bis dd.mm.yyyy'|

  # English: lending manager
  Szenario: Benutzerolle "Ausleihe-Verwalter"
    Angenommen man ist Ausleihe-Verwalter
    Wenn man im Inventar Bereich ist
    Dann kann man neue Gegenstände erstellen
    Und diese Gegenstände ausschliesslich nicht inventarrelevant sind
    Und man kann Optionen erstellen
    Und man kann neue Benutzer erstellen und für die Ausleihe sperren
    Und man kann nicht inventarrelevante Gegenstände ausmustern, sofern man deren Besitzer ist

  # English: inventory manager 
  @upcoming
  Szenario: Benutzerolle "Inventar-Verwalter"
    Angenommen man ist Inventar-Verwalter
    Dann kann man neue Modelle erstellen
    Und kann man neue Gegenstände erstellen
    Und diese Gegenstände können inventarrelevant sein
    Und man kann sie einem anderen Gerätepark als Besitzer zuweisen
    Und man kann die verantwortliche Abteilung eines Gegenstands frei wählen
    Und man kann Gegenstände ausmustern, sofern man deren Besitzer ist
    Und man kann Ausmusterungen wieder zurücknehmen, sofern man Besitzer der jeweiligen Gegenstände ist
    Und man kann die Arbeitstage und Ferientage seines Geräteparks anpassen
    Und man kann Benutzern die folgende Rollen zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist
    | role                |
    | Kein Zugriff        |
    | Kunde               |
    | Ausleihe-Verwalter  |
    | Inventar-Verwalter  |
    Und man kann alles, was ein Ausleihe-Verwalter kann

  @javascript
  Szenario: Als Administrator neuen Benutzer erstellen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Wenn man von hier auf die Benutzererstellungsseite geht
    Und den Nachnamen eingibt
    Und den Vornahmen eingibt
    Und die Email-Addresse eingibt
    Und man gibt die Login-Daten ein
    Und man speichert den neuen Benutzer
    Dann wird man auf die Benutzerliste ausserhalb der Inventarpools umgeleitet
    Und man sieht eine Bestätigungsmeldung
    Und der neue Benutzer wurde erstellt
    Und er hat keine Zugriffe auf Inventarpools und ist kein Administrator

  Szenario: Als Administrator einen anderen Benutzer Administrator machen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Editierseite eines Benutzers, der kein Administrator ist
    Wenn man diesen Benutzer die Rolle Administrator zuweist
    Und man speichert den Benutzer
    Dann sieht man die Erfolgsbestätigung
    Und hat dieser Benutzer die Rolle Administrator

  Szenario: Als Administrator einem anderen Benutzer die Rolle Administrator wegnehmen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Editierseite eines Benutzers, der ein Administrator ist
    Wenn man diesem Benutzer die Rolle Administrator wegnimmt
    Und man speichert den Benutzer
    Dann hat dieser Benutzer die Rolle Administrator nicht mehr

  Szenariogrundriss: Als Ausleihe- oder Inventar-Verwalter hat man kein Zugriff auf die Administrator-User-Pfade
    Angenommen man ist "<Person>"
    Wenn man versucht auf die Administrator Benutzererstellenansicht zu gehen
    Dann gelangt man auf diese Seite nicht
    Wenn man versucht auf die Administrator Benutzereditieransicht zu gehen
    Dann gelangt man auf diese Seite nicht

    Beispiele:
      | Person |
      | Pius   |
      | Mike   |

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
    Und eine der folgenden Rollen auswählt
    | tab                | role              |
    | Kunde              | customer          |
    | Ausleihe-Verwalter | lending_manager   |
    Und man teilt mehrere Gruppen zu
    Und man speichert
    Dann ist der Benutzer mit all den Informationen gespeichert

  @javascript
  Szenario: Neuen Benutzer im Geräterpark als Ausleihe-Verwalter hinzufügen
    Angenommen man ist "Pius"
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access |
      | Customer  |
    Und eine der folgenden Rollen auswählt
      | tab                | role              |
      | Kunde              | customer          |
    Und man teilt mehrere Gruppen zu
    Und man speichert
    Dann ist der Benutzer mit all den Informationen gespeichert

  @javascript
  Szenario: Neuen Benutzer im Geräterpark als Administrator hinzufügen
    Angenommen man ist "Gino"
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Lending manager    |
      | Inventory manager  |
    Und eine der folgenden Rollen auswählt
      | tab                | role                |
      | Kunde              | customer            |
      | Ausleihe-Verwalter | lending_manager     |
      | Inventar-Verwalter | inventory_manager   |
    Und man teilt mehrere Gruppen zu
    Und man speichert
    Dann ist der Benutzer mit all den Informationen gespeichert

  @javascript
  Szenariogrundriss: Neuen Benutzer hinzufügen - ohne Eingabe der Pflichtfelder
    Angenommen man ist "Pius"
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und alle Pflichtfelder sind sichtbar und abgefüllt
    Wenn man ein <Pflichtfeld> nicht eingegeben hat
    Und man speichert
    Dann sehe ich eine Fehlermeldung

    Beispiele:
      | Pflichtfeld |
      | Nachname    |
      | Vorname     |
      | E-Mail      |

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

  @javascript
  Szenario: Voraussetzungen fürs Löschen eines Benutzers
    Angenommen man ist "Ramon"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus
    Dann wird der Delete Button für diese Benutzer nicht angezeigt

  @javascript
  Szenario: Voraussetzungen fürs Löschen eines Benutzers im Gerätepark
    Angenommen man ist "Ramon"
    Und man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus
    Und man befindet sich auf der Benutzerliste im beliebigen Inventarpool
    Dann wird der Delete Button für diese Benutzer nicht angezeigt

  Szenario: Alphabetische Sortierung der Benutzer ausserhalb vom Inventarpool
    Angenommen man ist "Gino"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Dann sind die Benutzer nach ihrem Vornamen alphabetisch sortiert

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

  @javascript
  Szenario: Benutzer den Zugriff auf ein Inventarpool reaktivieren
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der mal einen Zugriff auf das aktuelle Inventarpool hatte
    Wenn man den Zugriff auf "Kunde" ändert
    Und man speichert den Benutzer
    Dann sieht man die Erfolgsbestätigung
    Und hat der Benutzer die Rolle Kunde
