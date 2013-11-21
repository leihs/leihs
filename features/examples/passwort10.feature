# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

  @javascript
  Szenariogrundriss: Benutzernamen und Passwort ändern
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzereditieransicht von "Normin"
    Wenn ich den Benutzernamen auf "newnorminusername" und das Passwort auf "newnorminpassword" ändere
    Und der Benutzer hat Zugriff auf ein Inventarpool
    Dann kann sich der Benutzer "newnorminusername" mit "newnorminpassword" anmelden

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |
