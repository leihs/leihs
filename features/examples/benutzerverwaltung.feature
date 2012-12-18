# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"

  Szenario: Benutzerolle "Ausleihe-Verwalter"
    Angenommen man ist Ausleihe-Verwalter
    Dann kann man neue Gegenstände erstellen, die ausschliesslich nicht inventarrelevant sind
    Und man kann Optionen erstellen
    Und man kann neue Benutzer erstellen und für die Ausleihe sperren
    Und man kann Benutzern die Rollen "Kunde" zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist
    Und man kann nicht inventarrelevante Gegenstände ausmustern, sofern man deren Besitzer ist

  Szenario: Benutzerolle "Inventar-Verwalter"
    Angenommen man ist Inventar-Verwalter
    Dann kann man neue Modelle erstellen
    Und man kann neue Gegenstände erstellen
    Und diese Gegenstände können inventarrelevant sein
    Und man kann sie einem anderen Gerätepark als Besitzer zuweisen
    Und man kann die verantwortliche Abteilung eines Gegenstands frei wählen
    Und man kann Gegenstände ausmustern, sofern man deren Besitzer ist
    Und man kann Ausmusterungen wieder zurücknehmen, sofern man Besitzer der jeweiligen Gegenstände ist
    Und man kann die Arbeitstage und Ferientage seines Geräteparks anpassen
    Und man kann Benutzern die Rollen "Kunde", "Ausleihe-Verwalter" und "Inventar-Verwalter" zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist
    Und man kann alles, was ein Ausleihe-Verwalter kann

  Szenario: Benutzerolle "Administrator"
    Angenommen man ist Administrator
    Dann kann man neue Geräteparks erstellen
    Und man kann neue Benutzer erstellen und löschen
    Und man kann Benutzern jegliche Rollen zuweisen und wegnehmen  

  Szenario: Elemente der Benutzeradministration 
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Dann findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"
    Dann sieht man eine Liste aller Benutzer
    Und man kann filtern nach den folgenden Eigenschaften: gesperrt
    Und man kann filtern nach den folgenden Rollen: Keine, Kunde, Ausleihe-Verwalter, Inventar-Verwalter, Administrator
    Und man kann für jeden Benutzer die Editieransicht aufrufen 
    Und man kann einen neuen Benutzer erstellen 

  Szenario: Elemente der Editieransicht
    Angenommen man editiert einen Benutzer
    Dann sieht man als Titel den Vornamen und Namen des Benutzers, sofern bereits vorhanden
    Dann sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:
    |Badge-Nummer|
    |Rollen|
    Dann sieht man die Sperrfunktion für diesen Benutzer
    Und sofern dieser Benutzer gesperrt ist, sieht man Grund und Dauer der Sperrung
    Dann sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:
    |Name|
    |Vorname|
    |Strasse|
    |PLZ|
    |Ort|
    |Land|
    |Telefonnummer|
    |E-Mail-Adresse|
    Und man kann die Informationen ändern, sofern es sich um einen externen Benutzer handelt
    Und man kann die Informationen nicht verändern, sofern es sich um einen Benutzer handelt, der über ein externes Authentifizierungssystem eingerichtet wurde
    Und man sieht die Rollen des Benutzers und kann diese entsprechend seiner Rolle verändern
    Und man kann die vorgenommenen Änderungen abspeichern 

  Szenario: Sperrfunktion
    Angenommen man editiert einen Benutzer
    Und man nutzt die Sperrfunktion
    Dann muss man den Grund der Sperrung eingeben
    Und man muss das Enddatum der Sperrung bestimmen 
    Und sofern der Benutzer gesperrt ist, kann man die Sperrung aufheben
