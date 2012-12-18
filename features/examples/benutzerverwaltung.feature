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
 
  Szenario: Benutzerrolle prüfen
    Angenommen man ist in der Benutzeradministration
    Dann sehe ich im Bereich 'Rollen' die zugeteilte Rolle
    Und verlasse den Bereich wieder indem ich einen anderen Bereich wähle oder auf Abbrechen klicke
    Und wieder auf der Übersicht des Benutzers lande
 
  Szenario: Wählen oder Ändern
    Angenommen man ist in der Benutzeradministration
    Dann wähle ich im Bereich 'Rollen' eine der Rollen 'Kunde', 'Ausleih-Manager' oder 'Inventar-Manager'
    Und speichere die Einstellung
    Und lande wieder auf der Übersicht des Benutzers'

