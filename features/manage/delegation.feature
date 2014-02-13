# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Auswahl der Delegation in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich versuche die Delegation zu wechseln
    Dann kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben

  @javascript
  Szenario: Auswahl der Kontaktperson in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung von einer Delegation
    Wenn ich versuche bei der Bestellung die Kontaktperson zu wechseln
    Dann kann ich als Kontaktperson nur diejenigen Personen wählen, die zur Delegationsgruppe gehören

  @javascript
  Szenario: Delegation in persönliche Bestellungen ändern in Bestellung
    Angenommen ich bin Pius
    Und es wurde für eine Delegation eine Bestellung erstellt
    Und ich befinde mich in dieser Bestellung
    Wenn ich statt einer Delegation einen Benutzer wähle
    Dann ist in der Bestellung der Benutzer aufgeführt
    Und es ist keine Kontaktperson aufgeführt

  @javascript
  Szenario: Delegation in persönliche Bestellungen ändern in Aushändigung
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung für eine Delegation
    Wenn ich statt einer Delegation einen Benutzer wähle
    Dann ist in der Aushändigung der Benutzer aufgeführt

  @javascript
  Szenario: Persönliche Bestellung in Delegationsbestellung ändern in Bestellung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich statt eines Benutzers eine Delegation wähle
    Und ich eine Kontaktperson aus der Delegation wähle
    Und ich bestätige den Benutzerwechsel
    Dann ist in der Bestellung der Name der Delegation aufgeführt
    Und ist in der Bestellung der Name der Kontaktperson aufgeführt

  @javascript
  Szenario: Persönliche Bestellung in Delegationsbestellung ändern in Aushändigung
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung
    Wenn ich statt eines Benutzers eine Delegation wähle
    Dann ist in der Bestellung der Name der Delegation aufgeführt

  @javascript
  Szenario: Aushändigen und eine Kontaktperson hinzufügen
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung
    Wenn ich die Gegenstände aushändige
    Dann muss ich eine Kontaktperson hinzufügen

  @javascript
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
