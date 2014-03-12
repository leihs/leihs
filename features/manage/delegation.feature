# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Einer Delegation einen gesperrten Verantwortlichen zuteilen 
    Angenommen ich bin Pius
    Und ich befinde mich in der Editieransicht einer Delegation
    Wenn ich einen Verantwortlichen zuteile
    Und der Verantwortliche ist für diesen Gerätepark gesperrt
    Dann ist dieser bei der Auswahl rot markiert
    Und hinter dem Namen steht in rot 'Gesperrt!'

  @javascript
  Szenario: Einer Delegation einen gesperrten Benutzer hinzufügen 
    Angenommen ich bin Pius
    Und ich befinde mich in der Editieransicht einer Delegation
    Wenn ich einen Benutzer hinzufüge
    Und der Benutzer ist für diesen Gerätepark gesperrt
    Dann ist er bei der Auswahl rot markiert
    Und in der Auwahl steht hinter dem Namen in rot 'Gesperrt!'
    Und in der Auflistung der Benutzer steht hinter dem Namen in rot 'Gesperrt!'

  @javascript
  Szenario: Kontaktperson bei Aushändigung wählen
    Angenommen ich bin Pius
    Und es existiert eine Aushändigung für eine Delegation mit zugewiesenen Gegenständen
    Und ich öffne diese Aushändigung
    Wenn ich die Aushändigung abschliesse
    Dann muss ich eine Kontaktperson auswählen 

  @javascript
  Szenario: Anzeige einer gesperrten Kontaktperson in Aushändigung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Aushändigung
    Wenn ich die Aushändigung abschliesse
    Und ich eine Kontaktperson wähle
    Und diese Kontaktperson ist gesperrt
    Dann ist diese Kontaktperson bei der Auswahl rot markiert
    Und in der Auwahl steht hinter dem Namen in rot 'Gesperrt!'

  @javascript
  Szenario: Auswahl einer gesperrten Kontaktperson in Bestellung
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Und ich wechsle den Benutzer
    Und ich wähle eine Delegation
    Wenn ich eine Kontaktperson wähle
    Und diese Kontaktperson ist für diesen Gerätepark gesperrt
    Dann ist er bei der Auswahl rot markiert
    Und in der Auwahl steht hinter dem Namen in rot 'Gesperrt!'

  @javascript
  Szenario: Delegation in persönliche Bestellungen ändern in Aushändigung
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung für eine Delegation
    Wenn ich statt einer Delegation einen Benutzer wähle
    Dann ist in der Aushändigung der Benutzer aufgeführt

  @javascript
  Szenario: Persönliche Bestellung in Delegationsbestellung ändern in Aushändigung
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung
    Wenn ich statt eines Benutzers eine Delegation wähle
    Dann ist in der Bestellung der Name der Delegation aufgeführt

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

  @javascript
  Szenario: Gesperrte Benutzer können keine Bestellungen senden
    Angenommen ich bin Julie
    Wenn ich von meinem Benutzer zu einer Delegation wechsle
    Und die Delegation ist für einen Gerätepark freigeschaltet
    Aber ich bin für diesen Gerätepark gesperrt
    Dann kann ich keine Gegenstände dieses Geräteparks absenden
