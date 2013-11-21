# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

  @javascript
  Szenariogrundriss: Benutzernamen ändern
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzereditieransicht von "Normin"
    Wenn ich den Benutzernamen von "Normin" auf "username" ändere
    Und der Benutzer hat Zugriff auf ein Inventarpool
    Dann kann sich der Benutzer "username" mit "password" anmelden

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |
