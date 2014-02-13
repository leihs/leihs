# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Delegation in Aushändigung ändern
    Angenommen ich bin Pius
    Und es existiert eine Aushändigung für eine Delegation
    Und ich öffne diese Aushändigung
    Wenn ich die Delegation wechsle
    Dann lautet die Aushändigung auf diese neu gewählte Delegation

  @javascript
  Szenario: Auswahl der Delegation in Aushändigung ändern
    Angenommen ich bin Pius
    Und ich öffne eine Aushändigung
    Wenn ich versuche die Delegation zu wechseln
    Dann kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben

  @javascript
  Szenario: Auswahl der Kontaktperson in Aushändigung ändern
    Angenommen ich bin Pius
    Und es existiert eine Aushändigung für eine Delegation mit zugewiesenen Gegenständen
    Und ich öffne diese Aushändigung
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

  @javascript
  Szenario: Auswahl der Delegation in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich versuche die Delegation zu wechseln
    Dann kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben

  @javascript
  Szenario: Auswahl der Kontaktperson in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich versuche die Kontaktperson zu wechseln
    Dann kann ich nur diejenigen Personen wählen, die zur Delegationsgruppe gehören

