# language: de

Funktionalität: Umleitung zur Anmeldung

  Um Aktionen als authentifizierter Benutzer durchführen zu können
  möchte ich als Benutzer
  vom System darauf hingewiesen werden sobald ich abgemeldet bin

  @javascript @personas
  Szenario: Ausführung einer Aktion für authentifizierte Benutzer ohne angemeldet zu sein
    Angenommen ich bin Pius
    Und versuche eine Aktion im Backend auszuführen obwohl ich abgemeldet bin
    Dann werden ich auf die Startseite weitergeleitet
    Und sehe einen Hinweis, dass ich nicht angemeldet bin