# language: de

Funktionalität: Delegation

  @javascript @personas
  Szenario: Einer Delegation einen gesperrten Verantwortlichen zuteilen
    Angenommen ich bin Pius
    Und ich befinde mich in der Editieransicht einer Delegation
    Wenn ich einen Verantwortlichen zuteile, der für diesen Gerätepark gesperrt ist
    Dann ist dieser bei der Auswahl rot markiert
    Und hinter dem Namen steht in rot 'Gesperrt!'

  @javascript @personas
  Szenario: Einer Delegation einen gesperrten Benutzer hinzufügen
    Angenommen ich bin Pius
    Und ich befinde mich in der Editieransicht einer Delegation
    Wenn ich einen Benutzer hinzufüge, der für diesen Gerätepark gesperrt ist
    Dann ist er bei der Auswahl rot markiert
    Und in der Auwahl steht hinter dem Namen in rot 'Gesperrt!'
    Und in der Auflistung der Benutzer steht hinter dem Namen in rot 'Gesperrt!'

  @javascript @personas
  Szenario: Kontaktperson bei Aushändigung wählen
    Angenommen ich bin Pius
    Und es existiert eine Aushändigung für eine Delegation mit zugewiesenen Gegenständen
    Und ich öffne diese Aushändigung
    Wenn ich die Aushändigung abschliesse
    Dann muss ich eine Kontaktperson auswählen

  @javascript @personas @firefox
  Szenario: Anzeige einer gesperrten Kontaktperson in Aushändigung
    Angenommen ich bin Pius
    Und es existiert eine Aushändigung für eine Delegation mit zugewiesenen Gegenständen
    Und ich öffne diese Aushändigung
    Wenn ich die Aushändigung abschliesse
    Und ich eine gesperrte Kontaktperson wähle
    Dann ist diese Kontaktperson bei der Auswahl rot markiert
    Und in der Auwahl steht hinter dem Namen in rot 'Gesperrt!'

  @javascript @personas @firefox
  Szenario: Auswahl einer gesperrten Kontaktperson in Bestellung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Und ich wechsle den Benutzer
    Und ich wähle eine Delegation
    Wenn ich eine Kontaktperson wähle, der für diesen Gerätepark gesperrt ist
    Dann ist er bei der Auswahl rot markiert
    Und in der Auwahl steht hinter dem Namen in rot 'Gesperrt!'

  @javascript @personas @firefox
  Szenario: Delegation in persönliche Bestellungen ändern in Aushändigung
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung für eine Delegation
    Wenn ich statt einer Delegation einen Benutzer wähle
    Dann ist in der Aushändigung der Benutzer aufgeführt

  @javascript @personas
  Szenario: Persönliche Bestellung in Delegationsbestellung ändern in Aushändigung
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung
    Wenn ich statt eines Benutzers eine Delegation wähle
    Dann ist in der Bestellung der Name der Delegation aufgeführt

  @javascript @personas
  Szenario: Anzeige des Tooltipps
    Angenommen ich bin Pius
    Wenn ich nach einer Delegation suche
    Und ich über den Delegationname fahre
    Dann werden mir im Tooltipp der Name und der Verantwortliche der Delegation angezeigt

  @javascript @personas
  Szenario: Globale Suche
    Angenommen ich bin Pius
    Und ich suche 'Julie'
    Wenn Julie in einer Delegation ist
    Dann werden mir im alle Suchresultate von Julie oder Delegation mit Namen Julie angezeigt
    Und mir werden alle Delegationen angezeigt, den Julie zugeteilt ist

  @personas
  Szenario: Gesperrte Benutzer können keine Bestellungen senden
    Angenommen ich bin Julie
    Wenn ich von meinem Benutzer zu einer Delegation wechsle
    Und die Delegation ist für einen Gerätepark freigeschaltet
    Aber ich bin für diesen Gerätepark gesperrt
    Dann kann ich keine Gegenstände dieses Geräteparks absenden

  @javascript @personas
  Szenario: Filter der Delegationen
    Angenommen ich bin Pius
    Wenn ich in den Admin-Bereich wechsel
    Und man befindet sich auf der Benutzerliste
    Dann kann ich in der Benutzerliste nach Delegationen einschränken
    Und ich kann in der Benutzerliste nach Benutzer einschränken

  @javascript @personas
  Szenario: Erfassung einer Delegation
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn ich eine neue Delegation erstelle
    Und ich der Delegation Zugriff für diesen Pool gebe
    Und ich dieser Delegation einen Namen gebe
    Und ich dieser Delegation keinen, einen oder mehrere Personen zuteile
    Und ich dieser Delegation keinen, einen oder mehrere Gruppen zuteile
    Und ich kann dieser Delegation keine Delegation zuteile
    Und ich genau einen Verantwortlichen eintrage
    Und ich speichere
    Dann ist die neue Delegation mit den aktuellen Informationen gespeichert

  @javascript @personas
  Szenario: Delegation erhält Zugriff als Kunde
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn ich eine neue Delegation erstelle
    Dann kann ich dieser Delegation ausschliesslich Zugriff als Kunde zuteilen

  @javascript @personas @firefox
  Szenario: Delegation in persönliche Bestellungen ändern in Bestellung
    Angenommen ich bin Pius
    Und es wurde für eine Delegation eine Bestellung erstellt
    Und ich befinde mich in dieser Bestellung
    Wenn ich statt einer Delegation einen Benutzer wähle
    Dann ist in der Bestellung der Benutzer aufgeführt
    Und es ist keine Kontaktperson aufgeführt

  @javascript @personas
  Szenario: Delegation erfassen ohne Pflichtfelder abzufüllen
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Und ich eine neue Delegation erstelle
    Wenn ich dieser Delegation einen Namen gebe
    Und ich keinen Verantwortlichen zuteile
    Und ich speichere
    Dann sehe ich eine Fehlermeldung
    Wenn ich genau einen Verantwortlichen eintrage
    Und ich keinen Namen angebe
    Und ich speichere
    Dann sehe ich eine Fehlermeldung

  @javascript @personas
  Szenario: Delegation editieren
    Angenommen ich bin Pius
    Und ich in den Admin-Bereich wechsel
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn ich eine Delegation editiere
    Und ich den Verantwortlichen ändere
    Und ich einen bestehenden Benutzer lösche
    Und ich der Delegation einen neuen Benutzer hinzufüge
    Und man teilt mehrere Gruppen zu
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und ist die bearbeitete Delegation mit den aktuellen Informationen gespeichert

  @javascript @personas
  Szenario: Delegation Zugriff entziehen
    Angenommen ich bin Pius
    Wenn ich eine Delegation mit Zugriff auf das aktuelle Gerätepark editiere
    Und ich dieser Delegation den Zugriff für den aktuellen Gerätepark entziehe
    Und ich speichere
    Dann können keine Bestellungen für diese Delegation für dieses Gerätepark erstellt werden

  @javascript @personas @firefox
  Szenario: Persönliche Bestellung in Delegationsbestellung ändern in Bestellung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich statt eines Benutzers eine Delegation wähle
    Und ich eine Kontaktperson aus der Delegation wähle
    Und ich bestätige den Benutzerwechsel
    Dann ist in der Bestellung der Name der Delegation aufgeführt
    Und ist in der Bestellung der Name der Kontaktperson aufgeführt

  @javascript @personas
  Szenario: Delegation löschen
    Angenommen ich bin Gino
    Und ich in den Admin-Bereich wechsle
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn keine Bestellung, Aushändigung oder ein Vertrag für eine Delegation besteht
    Und wenn für diese Delegation keine Zugriffsrechte für irgendwelches Gerätepark bestehen
    Dann kann ich diese Delegation löschen

  #  ANZEIGE BACKEND

  @personas
  Szenario: Anzeige der Bestellungen für eine Delegation
    Angenommen ich bin Pius
    Und es wurde für eine Delegation eine Bestellung erstellt
    Und ich befinde mich in dieser Bestellung
    Dann sehe ich den Namen der Delegation
    Und ich sehe die Kontaktperson

  @javascript @personas @firefox
  Szenario: Definition Kontaktperson auf Auftragserstellung
    Angenommen ich bin Julie
    Wenn ich eine Bestellung für eine Delegationsgruppe erstelle
    Dann bin ich die Kontaktperson für diesen Auftrag
    Angenommen heute entspricht dem Startdatum der Bestellung
    Und ich bin Pius
    Wenn ich die Gegenstände für die Delegation an "Mina" aushändige
    Dann ist "Mina" die neue Kontaktperson dieses Auftrages

  @personas
  Szenario: Anzeige der Bestellungen einer persönlichen Bestellung
    Angenommen ich bin Pius
    Und es existiert eine persönliche Bestellung
    Und ich befinde mich in dieser Bestellung
    Dann ist in der Bestellung der Name des Benutzers aufgeführt
    Und ich sehe keine Kontatkperson

  @javascript @personas
  Szenario: Delegation in Aushändigung ändern
    Angenommen ich bin Pius
    Und es existiert eine Aushändigung für eine Delegation
    Und ich öffne diese Aushändigung
    Wenn ich die Delegation wechsle
    Und ich bestätige den Benutzerwechsel
    Dann lautet die Aushändigung auf diese neu gewählte Delegation

  @javascript @personas
  Szenario: Auswahl der Delegation in Aushändigung ändern
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung
    Wenn ich versuche die Delegation zu wechseln
    Dann kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben

  @javascript @personas @firefox
  Szenario: Auswahl der Kontaktperson in Aushändigung ändern
    Angenommen ich bin Pius
    Und es existiert eine Aushändigung für eine Delegation mit zugewiesenen Gegenständen
    Und ich öffne diese Aushändigung
    Wenn ich versuche die Kontaktperson zu wechseln
    Dann kann ich nur diejenigen Personen wählen, die zur Delegationsgruppe gehören

  @javascript @personas @firefox
  Szenario: Auswahl der Kontaktperson in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung von einer Delegation
    Wenn ich versuche bei der Bestellung die Kontaktperson zu wechseln
    Dann kann ich bei der Bestellung als Kontaktperson nur diejenigen Personen wählen, die zur Delegationsgruppe gehören

  @javascript @personas @firefox
  Szenario: Borrow: Bestellung erfassen mit Delegation
    Angenommen ich bin Julie
    Wenn ich über meinen Namen fahre
    Und ich auf "Delegationen" drücke
    Dann werden mir die Delegationen angezeigt, denen ich zugeteilt bin
    Wenn ich eine Delegation wähle
    Dann wechsle ich die Anmeldung zur Delegation
    Angenommen man befindet sich auf der Modellliste
    Wenn man auf einem verfügbaren Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn alle Angaben die ich im Kalender mache gültig sind
    Dann lässt sich das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügen
    Wenn ich die Bestellübersicht öffne
    Und ich einen Zweck eingebe
    Und man merkt sich die Bestellung
    Und ich die Bestellung abschliesse
    Und ich refreshe die Bestellung
    Dann ändert sich der Status der Bestellung auf Abgeschickt
    Und die Delegation ist als Besteller gespeichert
    Und ich werde als Kontaktperson hinterlegt

  @javascript @personas @firefox
  Szenario: Delegation in Bestellungen ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich die Delegation wechsle
    Und ich die Kontaktperson wechsle
    Und ich bestätige den Benutzerwechsel
    Dann lautet die Aushändigung auf diese neu gewählte Delegation
    Und die neu gewählte Kontaktperson wird gespeichert

  @javascript @personas
  Szenario: Auswahl der Delegation in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich versuche die Delegation zu wechseln
    Dann kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben

  @javascript @personas
  Szenario: Delegation wechseln - nur ein Kontaktpersonfeld
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung von einer Delegation
    Wenn ich die Delegation wechsle
    Dann sehe ich genau ein Kontaktpersonfeld

  @javascript @personas
  Szenario: Delegation wechseln - Kontaktperson ist ein Muss
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich die Delegation wechsle
    Und ich keine Kontaktperson angebe
    Und ich den Benutzerwechsel bestätige
    Dann sehe ich im Dialog die Fehlermeldung "Die Kontaktperson ist nicht Mitglied der Delegation oder ist leer"
