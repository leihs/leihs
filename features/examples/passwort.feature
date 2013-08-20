# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

  Grundlage:
    Angenommen personas existing

  @javascript
  Szenariogrundriss: Benutzer mit Benutzernamen und Passwort erstellen
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzerliste
    Wenn ich einen Benutzer mit Login "username" und Passwort "password" erstellt habe
    Und der Benutzer hat Zugriff auf ein Inventarpool
    Dann kann sich der Benutzer "username" mit "password" anmelden

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

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

  @javascript
  Szenariogrundriss: Benutzer ohne Loginnamen erstellen
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzerliste
    Wenn ich einen Benutzer ohne Loginnamen erstellen probiere
    Dann sehe ich eine Fehlermeldung

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @javascript
  Szenariogrundriss: Benutzer mit falscher Passwort-Bestätigung erstellen
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzerliste
    Wenn ich einen Benutzer mit falscher Passwort-Bestätigung erstellen probiere
    Dann sehe ich eine Fehlermeldung

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

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

  @javascript
  Szenariogrundriss: Benutzer mit falscher Passwort-Bestätigung editieren
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzereditieransicht von "Normin"
    Wenn ich eine falsche Passwort-Bestägigung eingebe und speichere
    Dann sehe ich eine Fehlermeldung

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @javascript
  Szenariogrundriss: Benutzer mit fehlenden Passwortangaben editieren
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzereditieransicht von "Normin"
    Wenn ich die Passwort-Angaben nicht eingebe und speichere
    Dann sehe ich eine Fehlermeldung

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |
