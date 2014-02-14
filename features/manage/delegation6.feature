# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Borrow: Bestellung erfassen mit Delegation
    Angenommen ich bin Julie
    Wenn ich über meinen Namen fahre
    Und ich auf "Delegationen" drücke
    Dann werden mir die Delegationen angezeigt, denen ich zugeteilt bin
    Wenn ich eine Delegation wähle
    Dann wechsle ich die Anmeldung zur Delegation
    Wenn ich habe Gegenstände der Bestellung hinzugefügt
    Und ich die Bestellübersicht öffne
    Und ich einen Zweck eingebe
    Und ich die Bestellung abschliesse
    Dann ändert sich der Status der Bestellung auf Abgeschickt
    Und die Delegation ist als Besteller gespeichert
    Und ich werde als Kontaktperson hinterlegt

  @javascript
  Szenario: Delegation in Bestellungen ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich die Delegation wechsle
    Und ich die Kontaktperson wechsle
    Und ich bestätige den Benutzerwechsel
    Dann lautet die Aushändigung auf diese neu gewählte Delegation
    Und die neu gewählte Kontaktperson wird gespeichert

  @javascript
  Szenario: Auswahl der Delegation in Bestellung ändern
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich versuche die Delegation zu wechseln
    Dann kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben
