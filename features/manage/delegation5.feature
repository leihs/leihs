# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Delegation in Aushändigung ändern
    Angenommen ich bin Pius
    Und es existiert eine Aushändigung für eine Delegation
    Und ich öffne diese Aushändigung
    Wenn ich die Delegation wechsle
    Und ich bestätige den Benutzerwechsel
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
    Wenn ich versuche die Kontaktperson zu wechseln
    Dann kann ich nur diejenigen Personen wählen, die zur Delegationsgruppe gehören

  @javascript
  Szenario: Auswahl der Kontaktperson in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung von einer Delegation
    Wenn ich versuche bei der Bestellung die Kontaktperson zu wechseln
    Dann kann ich bei der Bestellung als Kontaktperson nur diejenigen Personen wählen, die zur Delegationsgruppe gehören
