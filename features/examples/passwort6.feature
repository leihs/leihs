# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

  @javascript
  Szenariogrundriss: Benutzer mit fehlenden Passwortangaben erstellen
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzerliste
    Wenn ich einen Benutzer mit fehlenden Passwortangaben erstellen probiere
    Dann sehe ich eine Fehlermeldung

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |
