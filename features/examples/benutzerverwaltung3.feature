# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

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
    | Gruppen-Verwalter   |
    | Ausleihe-Verwalter  |
    | Inventar-Verwalter  |
    Und man kann alles, was ein Ausleihe-Verwalter kann
