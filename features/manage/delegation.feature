# language: de

Funktionalität: Delegation

  Szenario: Filter der Delegationen
    Angenommen ich bin Pius
    Wenn ich in den Admin-Bereich wechsel
    Und man befindet sich auf der Benutzerliste
    Dann kann ich in der Benutzerliste nach Delegationen einschränken
    Und ich kann in der Benutzerliste nach Benutzer einschränken

  @upcoming
  Szenario: Erfassung einer Delegation
    Angenommen ich bin Pius
    Und ich befinde mich im Admin-Bereich
    Wenn ich im Reiter Benutzer eine neue Delegation erstelle
    Und ich der Delegation Zugriff für diesen Pool gebe
    Und ich dieser Delegation einen Namen gebe
    Und ich dieser Delegation keinen, einen oder mehrere Personen zuteile
    Und ich kann dieser Delegation keine Delegation zuteile
    Und ich genau einen Verantwortlichen eintrage
    Und ich die Delegation speichere
    Dann ist die Delegation mit den aktuellen Informationen gespeichert

  @upcoming
  Szenario: Delegation erhält Zugriff als Kunde
    Angenommen ich bin Pius
    Und ich befinde mich im Admin-Bereich
    Wenn ich eine Delegation erstelle
    Dann kann ich dieser Delegation ausschliesslich Zugriff als Kunde zuteilen


  @upcoming
  Szenario: Delegation erfassen ohne Pflichtfelder abzufüllen
    Angenommen ich bin Pius
    Und ich erstelle eine neue Delegation
    Wenn ich keinen Verantwortlichen zuteile
    Dann erhalte ich eine Fehlermeldung
    Und ich keinen Namen angebe
    Dann erhalte ich eine Fehlermeldung

  @upcoming
  Szenario: Delegation editieren
    Angenommen ich bin Pius
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn ich eine Delegation editiere
    Und ich den Verantwortlichen ändere
    Und ich einen bestehenden Benutzer lösche
    Und ich einen neuen Benutzer hinzufüge
    Und ich die Delegation speichere
    Dann ist die Delegation mit den aktuellen Informationen gespeichert

  @upcoming
  Szenario: Delegation Zugriff entziehen
    Angenommen ich bin Pius
    Und ich befinde mich in der Editieransicht einer Delegation
    Wenn ich dieser Delegation den Zugriff für den aktuellen Gerätepark entziehe
    Dann können keine Bestellungen oder Aushändungen für diese Delegation erstellt werden

  @upcoming
  Szenario: Delegation löschen
    Angenommen ich bin Pius
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn keine Bestellung, Aushändigung oder ein Vertrag für eine Delegation besteht
    Und wenn für diese Delegation keine Zugriffsrechte für andere Geräteparks bestehen
    Dann kann ich diese Delegation löschen

  #  ANZEIGE BACKEND

  @upcoming
  Szenario: Anzeige der Bestellungen für eine Delegation
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn die Bestellung für eine Delegation erstellt wurde
    Dann sehe ich den Namen der Delegation
    Und ich sehe die Kontaktperson

  @upcoming
  Szenario: Definition Kontaktperson auf Auftragserstellung
    Angenommen ich bin Julie
    Wenn ich eine Bestellung für eine Delegationsgruppe erstelle
    Dann bin ich die Kontaktperson für diesen Auftrag
    Angenommen ich bin Mina
    Wenn ich die Gegenstände abhole
    Dann bin ich die neue Kontaktperson dieses Auftrages

  @upcoming
  Szenario: Anzeige der Bestellungen einer persönlichen Bestellung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Und diese Bestellung ist eine persönliche Bestellung
    Dann ist in der Bestellung der Name des Benutzers aufgeführt
    Und ich sehe keine Kontatkperson

  @upcoming
  Szenario: Delegation in Aushändigung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Aushändigung
    Wenn ich die Delegation wechsle
    Dann lautet die Aushändigung auf diese neu gewählte Delegation

  @upcoming
  Szenario: Auswahl der Delegation in Aushändigung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Aushändigung
    Wenn ich die Delegation wechsle
    Dann kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben

  @upcoming
  Szenario: Auswahl der Kontaktperson in Aushändigung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Aushändigung
    Wenn ich die Kontaktperson wechsle
    Dann kann ich nur diejenigen Personen wählen, die zur Delegationsgruppe gehören

  @upcoming
  Szenario: Delegation in Bestellungen ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich den Delegation wechsle
    Und ich die Kontaktperson wechsle
    Dann lautet die Aushändigung auf diese neu gewählte Delegation
    Und die neu gewählte Kontaktperson wird gespeichert

  @upcoming
  Szenario: Auswahl der Delegation in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich die Delegation wechsle
    Dann kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben

  @upcoming
  Szenario: Auswahl der Kontaktperson in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich die Kontaktperson wechsle
    Dann kann ich nur diejenigen Personen wählen, die zur Delegationsgruppe gehören

  @upcoming
  Szenario: Delegation in persönliche Bestellungen ändern in Bestellung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich statt einer Delegation einen Benutzer wähle
    Dann ist in der Bestellung der Benutzer aufgeführt
    Und es ist keine Kontaktperson aufgeführt

  @upcoming
  Szenario: Delegation in persönliche Bestellungen ändern in Aushändigung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Aushändigung
    Wenn ich statt einer Delegation einen Benutzer wähle
    Dann ist in der Aushändigung der Benutzer aufgeführt

  @upcoming
  Szenario: Persönliche Bestellung in Delegationsbestellung ändern in Bestellung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich statt eines Benutzers eine Delegation wähle
    Dann ist in der Bestellung der Name der Delegation aufgeführt
    Und der Besteller wird als Kontaktperson angezeigt

  @upcoming
  Szenario: Persönliche Bestellung in Delegationsbestellung ändern in Aushändigung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Aushändigung
    Wenn ich statt eines Benutzers eine Delegation wähle
    Dann ist in der Bestellung der Name der Delegation aufgeführt

  @upcoming
  Szenario: Aushändigen und eine Kontaktperson hinzufügen
    Angenommen ich bin Pius
    Und ich befinde mich in einer Aushändigung
    Wenn ich die Gegenstände aushändige
    Dann muss ich eine Kontaktperson hinzufügen

  @upcoming
  Szenario: Anzeige des Tooltipps
    Angenommen ich bin Pius
    Wenn ich nach einer Delegation suche
    Und ich über den Delegationname fahre
    Dann werden mir im Tooltipp der Name und der Verantwortliche der Delegation angezeigt

  @javascript
  Szenario: Globale Suche
    Angenommen ich bin Pius
    Und ich suche 'Julie'
    Wenn Julie in einer Delegation ist
    Dann werden mir im alle Suchresultate von Julie oder Delegation mit Namen Julie angezeigt
    Und mir werden alle Delegationen angezeigt, den Julie zugeteilt ist

  @upcoming
  Szenario: Borrow: Bestellung erfassen mit Delegation
    Angenommen ich bin Julie
    Wenn ich über meinen Namen fahre
    Und ich auf 'Delegationen' drücke
    Dann werden mir die Delegationen angezeigt, denen ich zugeteilt bin
    Wenn ich eine Delegation wähle
    Dann wechsle ich die Anmeldung zur Delegation
    Wenn ich eine Bestellung abschicke
    Dann wird die Bestellung gespeichert
    Und die Delegation ist als Besteller gespeichert
    Und ich werde als Kontaktperson hinterlegt
