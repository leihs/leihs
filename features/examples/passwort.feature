# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

  Szenariogrundriss: Benutzer login
    Angenommen man ist "<Person>"
    Wenn ich ein Benutzer mit Login "niceuser" und Passwort "evennicerpassword" erstellt habe
    Dann kann sich der Benutzer "niceuser" mit "evennicerpassword" anmelden
    Beispiele:
      | Person |  
      | Mike   |  
      | Pius   |  
      | Gino   |  


  Szenariogrundriss: Passwort ändern
    Angenommen man ist "<Person>"
    Wenn ich das Passwort von "Normin" auf "newnorminpassword" ändere
    Dann kann sich der Benutzer "normin" mit "newnorminpassword" anmelden
    Beispiele:
      | Person |  
      | Mike   |  
      | Pius   |  
      | Gino   |  
