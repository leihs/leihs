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
    
  @javascript
  Szenario: Kalender max. Verfügbarkeit
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Dann wird die maximal ausleihbare Anzahl des ausgewählten Modells angezeigt
    Und man kann maximal die maximal ausleihbare Anzahl eingeben

  @javascript
  Szenario: Auswählbare Geräteparks im Kalender
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Dann sind nur diejenigen Geräteparks auswählbar, welche über Kapizäteten für das ausgewählte Modell verfügen
    Und die Geräteparks sind alphabetisch sortiert
    
  @javascript
  Szenario: Kalender Anzeige der Schliesstage
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet