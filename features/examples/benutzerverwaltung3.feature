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
    Und man speichert den Benutzer
    Dann wird man auf die Benutzerliste ausserhalb der Inventarpools umgeleitet
    Und man sieht eine Bestätigungsmeldung
    Und der neue Benutzer wurde erstellt
    Und er hat keine Zugriffe auf Inventarpools und ist kein Administrator

  Szenario: Als Administrator einen anderen Benutzer Administrator machen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Editierseite eines Benutzers, der kein Administrator ist und der Zugriffe auf Inventarpools hat
    Wenn man diesen Benutzer die Rolle Administrator zuweist
    Und man speichert den Benutzer
    Dann sieht man die Erfolgsbestätigung
    Und hat dieser Benutzer die Rolle Administrator
    Und alle andere Zugriffe auf Inventarpools bleiben beibehalten

  Szenario: Als Administrator einem anderen Benutzer die Rolle Administrator wegnehmen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Editierseite eines Benutzers, der ein Administrator ist und der Zugriffe auf Inventarpools hat
    Wenn man diesem Benutzer die Rolle Administrator wegnimmt
    Und man speichert den Benutzer
    Dann hat dieser Benutzer die Rolle Administrator nicht mehr
    Und alle andere Zugriffe auf Inventarpools bleiben beibehalten

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