# language: de

Funktionalität: Benutzeransicht

  Als Benutzer möchte ich die Möglichkeit haben meine Benutzerdaten zu sehen

  Grundlage:
    Angenommen man ist "Normin"

  Szenario: Benutzerdaten ansehen
    Wenn ich auf meinen Namen klicke
    Dann gelange ich auf die Seite der Benutzerdaten
    Und werden mir meine Benutzerdaten angezeigt
    Und die Benutzerdaten beinhalten
    |Vorname|
    |Nachname|
    |E-Mail|
    |Telefon|
    
  @javascript
  Szenario: Benutzerdaten unter dem Benutzername
    Wenn ich über meinen Namen fahre
    Dann sehe ich im Dropdown eine Schaltfläche die zur Benutzeransicht führt
