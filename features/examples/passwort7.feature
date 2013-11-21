# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

  @javascript
  Szenariogrundriss: Benutzer ohne Loginnamen editieren
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzereditieransicht von "Normin"
    Wenn ich den Benutzernamen von nicht ausfülle und speichere
    Dann sehe ich eine Fehlermeldung

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |
