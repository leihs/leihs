# language: de

Funktionalität: Kalender

  Um einen Gegenstand einer Bestellung hinzuzufügen
  möchte ich als Ausleihender
  den Gegenstand der Bestellung hinzufügen können

  @javascript
  Szenario: Kalender Verfügbarkeitsanzeige
    Angenommen man ist "Normin"
    Und es existiert ein Modell für das eine Bestellung vorhanden ist
    Wenn man dieses Modell aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und wird die Verfügbarkeit des Modells im Kalendar angezeigt
    
  @javascript
  Szenario: Kalender Verfügbarkeitsanzeige nach Änderung der Kalenderdaten
    Angenommen man ist "Normin"
    Und es existiert ein Modell für das eine Bestellung vorhanden ist
    Wenn man dieses Modell aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Wenn man ein Start und Enddatum ändert
    Dann wird die Verfügbarkeit des Gegenstandes aktualisiert
    Wenn man die Anzahl ändert
    Dann wird die Verfügbarkeit des Gegenstandes aktualisiert
