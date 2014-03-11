# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Delegation wechseln - nur ein Kontaktpersonfeld
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung von einer Delegation
    Wenn ich die Delegation wechsle
    Dann sehe ich genau ein Kontaktpersonfeld

  @javascript
  Szenario: Delegation wechseln - Kontaktperson ist ein Muss
    Angenommen ich bin Pius
    Und ich befinde mich in einer Bestellung
    Wenn ich die Delegation wechsle
    Und ich keine Kontaktperson angebe
    Und ich den Benutzerwechsel bestätige
    Dann sehe ich im Dialog die Fehlermeldung "Die Kontaktperson ist nicht Mitglied der Delegation oder ist leer"
