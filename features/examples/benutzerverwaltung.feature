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
    #Und man kann einen neuen Benutzer erstellen 

  @javascript
  Szenario: Sperrfunktion
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und man editiert einen Benutzer
    Und man nutzt die Sperrfunktion
    Dann muss man den Grund der Sperrung eingeben
    Und man muss das Enddatum der Sperrung bestimmen 
    Und sofern der Benutzer gesperrt ist, kann man die Sperrung aufheben

  @javascript
  Szenario: Elemente der Editieransicht
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und man editiert einen Benutzer
    Dann sieht man als Titel den Vornamen und Namen des Benutzers, sofern bereits vorhanden
    Dann sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:
    |en       |de           |
    |Badge ID |Badge-Nummer |
    |Role     |Rollen       |
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
    Dann kann man neue Gegenstände erstellen
    Und diese Gegenstände ausschliesslich nicht inventarrelevant sind
    Und man kann Optionen erstellen
    Und man kann neue Benutzer erstellen und für die Ausleihe sperren
    Und man kann Benutzern die folgende Rollen zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist
    | role           |
    | Kunde          |
    Und man kann nicht inventarrelevante Gegenstände ausmustern, sofern man deren Besitzer ist

  # English: inventory manager 
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
    | Kunde               |
    | Ausleihe-Verwalter  |
    | Inventar-Verwalter  |
    Und man kann alles, was ein Ausleihe-Verwalter kann

  Szenario: Benutzerolle "Administrator"
    Angenommen man ist Administrator
    Dann kann man neue Geräteparks erstellen
    Und man kann neue Benutzer erstellen und löschen
    Und man kann Benutzern jegliche Rollen zuweisen und wegnehmen  

  @javascript
  Szenario: Gruppenzuteilung in Benutzeransicht hinzufügen/entfernen
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer
    Dann kann man Gruppen über eine Autocomplete-Liste hinzufügen
    Und kann Gruppen entfernen
    Und speichert den Benutzer
    Dann ist die Gruppenzugehörigkeit gespeichert 
