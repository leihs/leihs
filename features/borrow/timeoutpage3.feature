# language: de

Funktionalität: Timeout Page

  @javascript
  Szenario: Eintrag ändern
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Und ich einen Eintrag ändere
    Dann werden die Änderungen gespeichert
    Und lande ich wieder auf der Timeout Page

  @javascript
  Szenario: Die Menge eines Eintrags heruntersetzen
    Angenommen man ist "Normin"
    Und ich zur Timeout Page mit einem Konfliktmodell weitergeleitet werde
    Wenn ich die Menge eines Eintrags heraufsetze
    Dann werden die Änderungen gespeichert
    Wenn ich die Menge eines Eintrags heruntersetze
    Dann werden die Änderungen gespeichert
    Und lande ich wieder auf der Timeout Page
