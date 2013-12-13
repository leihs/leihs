# language: de

Funktionalität: Kalender

  Um einen Gegenstand einer Bestellung hinzuzufügen
  möchte ich als Ausleihender
  den Gegenstand der Bestellung hinzufügen können
  
    
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
