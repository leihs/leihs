# language: de

Funktionalität: Kalender

  Um einen Gegenstand einer Bestellung hinzuzufügen
  möchte ich als Ausleihender
  den Gegenstand der Bestellung hinzufügen können
     
  @javascript
  Szenario: Kalender zwischen Monaten hin und herspringen
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Wenn man zwischen den Monaten hin und herspring
    Dann wird der Kalender gemäss aktuell gewähltem Monat angezeigt
    
  @javascript
  Szenario: Kalender Sprung zu Start und Enddatum
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Wenn man anhand der Sprungtaste zum aktuellen Startdatum springt
    Dann wird das Startdatum im Kalender angezeigt
    Wenn man anhand der Sprungtaste zum aktuellen Enddatum springt
    Dann wird das Enddatum im Kalender angezeigt
    
  @javascript
  Szenario: Meiner Bestellung einen Gegenstand hinzufügen
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und man auf einem Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn alle Angaben die ich im Kalender mache gültig sind
    Dann ist das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt worden

  @javascript
  Szenario: Kalender Bestellung nicht möglich, wenn Auswahl nicht verfügbar
    Angenommen man ist "Normin"
    Wenn man versucht ein Modell zur Bestellung hinzufügen, welches nicht verfügbar ist
    Dann schlägt der Versuch es hinzufügen fehl
    Und ich sehe die Fehlermeldung, dass das ausgewählte Modell im ausgewählten Zeitraum nicht verfügbar ist

  @javascript
  Szenario: Bestellkalender schliessen
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und man auf einem Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn ich den Kalender schliesse
    Dann schliesst das Dialogfenster