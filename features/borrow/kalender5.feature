# language: de

Funktionalität: Kalender

  Um einen Gegenstand einer Bestellung hinzuzufügen
  möchte ich als Ausleihender
  den Gegenstand der Bestellung hinzufügen können

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
