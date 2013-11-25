# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

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
