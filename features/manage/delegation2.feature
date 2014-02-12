# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Filter der Delegationen
    Angenommen ich bin Pius
    Wenn ich in den Admin-Bereich wechsel
    Und man befindet sich auf der Benutzerliste
    Dann kann ich in der Benutzerliste nach Delegationen einschränken
    Und ich kann in der Benutzerliste nach Benutzer einschränken

  @javascript
  Szenario: Erfassung einer Delegation
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn ich eine neue Delegation erstelle
    Und ich der Delegation Zugriff für diesen Pool gebe
    Und ich dieser Delegation einen Namen gebe
    Und ich dieser Delegation keinen, einen oder mehrere Personen zuteile
    Und ich kann dieser Delegation keine Delegation zuteile
    Und ich genau einen Verantwortlichen eintrage
    Und ich speichere
    Dann ist die neue Delegation mit den aktuellen Informationen gespeichert

  @javascript
  Szenario: Delegation erhält Zugriff als Kunde
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn ich eine neue Delegation erstelle
    Dann kann ich dieser Delegation ausschliesslich Zugriff als Kunde zuteilen
