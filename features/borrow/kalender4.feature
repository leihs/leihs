# language: de

Funktionalität: Kalender

  Um einen Gegenstand einer Bestellung hinzuzufügen
  möchte ich als Ausleihender
  den Gegenstand der Bestellung hinzufügen können
  
  @javascript
  Szenario: Bestellkalender nutzen nach dem man alle Filter zurückgesetzt hat
    Angenommen man ist "Normin"
    Wenn ich ein Modell der Bestellung hinzufüge
    Und man sich auf der Modellliste befindet
    Und man den zweiten Gerätepark in der Geräteparkauswahl auswählt
    Wenn man "Alles zurücksetzen" wählt
    Und man auf einem Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn alle Angaben die ich im Kalender mache gültig sind
    Dann lässt sich das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügen

  @javascript
  Szenario: Etwas bestellen, was nur Gruppen vorbehalten ist
    Angenommen man ist "Normin"
    Wenn ein Modell existiert, welches nur einer Gruppe vorbehalten ist
    Dann kann ich dieses Modell ausleihen, wenn ich in dieser Gruppe bin