# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

  @javascript
  Szenariogrundriss: Passwort ändern
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzereditieransicht von "Normin"
    Wenn ich das Passwort von "Normin" auf "newnorminpassword" ändere
    Und der Benutzer hat Zugriff auf ein Inventarpool
    Dann kann sich der Benutzer "normin" mit "newnorminpassword" anmelden

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |
