# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Delegation erfassen ohne Pflichtfelder abzufüllen
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Und ich eine neue Delegation erstelle
    Wenn ich keinen Verantwortlichen zuteile
    Dann erhalte ich eine Fehlermeldung
    Und ich keinen Namen angebe
    Dann erhalte ich eine Fehlermeldung

  @javascript
  Szenario: Delegation editieren
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn ich eine Delegation editiere
    Und ich den Verantwortlichen ändere
    Und ich einen bestehenden Benutzer lösche
    Und ich einen neuen Benutzer hinzufüge
    Und ich speichere
    Dann ist die Delegation mit den aktuellen Informationen gespeichert

  @javascript
  Szenario: Delegation Zugriff entziehen
    Angenommen ich bin Pius
    Und ich befinde mich in der Editieransicht einer Delegation
    Wenn ich dieser Delegation den Zugriff für den aktuellen Gerätepark entziehe
    Dann können keine Bestellungen oder Aushändungen für diese Delegation erstellt werden
