# language: de

Funktionalität: Bestellfensterchen

  Um Gegenstände ausleihen zu können
  möchte ich als Ausleiher
  die möglichkeit haben Modelle zu bestellen

  Grundlage:
    Angenommen man ist "Normin"
    
  @javascript
  Szenario: Zeit abgelaufen
    Wenn die Zeit abgelaufen ist
    Dann werde ich auf die Timeout Page weitergeleitet

  @javascript
  Szenario: Zeit überschritten
    Wenn ich ein Modell der Bestellung hinzufüge
    Dann sehe ich die Zeitanzeige
    Wenn die Zeit überschritten ist
    Dann werde ich auf die Timeout Page weitergeleitet
