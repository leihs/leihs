# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Als Administrator neuen Benutzer erstellen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Wenn man von hier auf die Benutzererstellungsseite geht
    Und den Nachnamen eingibt
    Und den Vornahmen eingibt
    Und die Email-Addresse eingibt
    Und man gibt die Login-Daten ein
    Und ich speichere
    Dann wird man auf die Benutzerliste ausserhalb der Inventarpools umgeleitet
    Und man sieht eine Bestätigungsmeldung
    Und der neue Benutzer wurde erstellt
    Und er hat keine Zugriffe auf Inventarpools und ist kein Administrator

  Szenario: Auflistung der Inventarpools eines Benutzers
    Angenommen man ist "Ramon"
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man einen Benutzer mit Zugriffsrechten editiert
    Dann werden die ihm zugeteilt Geräteparks mit entsprechender Rolle aufgelistet
