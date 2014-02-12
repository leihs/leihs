# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Delegation erfassen ohne Pflichtfelder abzufüllen
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Und ich eine neue Delegation erstelle
    Wenn ich dieser Delegation einen Namen gebe
    Und ich keinen Verantwortlichen zuteile
    Und ich speichere
    Dann sehe ich eine Fehlermeldung
    Wenn ich genau einen Verantwortlichen eintrage
    Und ich keinen Namen angebe
    Und ich speichere
    Dann sehe ich eine Fehlermeldung

  @javascript
  Szenario: Delegation editieren
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn ich eine Delegation editiere
    Und ich den Verantwortlichen ändere
    Und ich einen bestehenden Benutzer lösche
    Und ich der Delegation einen neuen Benutzer hinzufüge
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und ist die bearbeitete Delegation mit den aktuellen Informationen gespeichert

  @javascript
  Szenario: Delegation Zugriff entziehen
    Angenommen ich bin Pius
    Wenn ich eine Delegation mit Zugriff auf das aktuelle Gerätepark editiere
    Und ich dieser Delegation den Zugriff für den aktuellen Gerätepark entziehe
    Und ich speichere
    Dann können keine Bestellungen für diese Delegation für dieses Gerätepark erstellt werden
