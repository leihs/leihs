# language: de

Funktionalität: Bestellübersicht

  Um die Bestellung in der Übersicht zu sehen
  möchte ich als Ausleiher
  die Möglichkeit haben meine bestellten Gegenstände in der Übersicht zu sehen

  Grundlage:
    Angenommen man ist "Normin"
    Und ich habe Gegenstände der Bestellung hinzugefügt
    Wenn ich die Bestellübersicht öffne

  @javascript
  Szenario: Zeit abgelaufen    
    Wenn die Zeit abgelaufen ist
    Dann werde ich auf die Timeout Page weitergeleitet

  @javascript
  Szenario: Zeit überschritten
    Wenn ich ein Modell der Bestellung hinzufüge
    Dann sehe ich die Zeitanzeige
    Wenn man befindet sich auf der Bestellübersicht
    Und  die Zeit überschritten ist
    Dann werde ich auf die Timeout Page weitergeleitet
