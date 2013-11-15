# language: de

Funktionalität: Kalender

  Um einen Gegenstand einer Bestellung hinzuzufügen
  möchte ich als Ausleihender
  den Gegenstand der Bestellung hinzufügen können

  @javascript
  Szenario: Kalenderkomponenten
    Angenommen man ist "Normin"
    Wenn man einen Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und der Kalender beinhaltet die folgenden Komponenten
    |Modellname                       |
    |Aktueller Monat                  |
    |Kalender                         |
    |Geräteparkauswahl                |
    |Startdatumfeld                   |
    |Enddatumfeld                     |
    |Anzahlfeld                       |
    |Artikel hinzufügen Schaltfläche  |
    |Abbrechen Schaltfläche           |

  @javascript
  Szenario: Kalender Grundeinstellung
    Angenommen man ist "Normin"
    Wenn man einen Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und das aktuelle Startdatum ist heute
    Und das Enddatum ist morgen
    Und die Anzahl ist 1
    Und es sind alle Geräteparks angezeigt die Gegenstände von dem Modell haben

  @javascript
  Szenario: Kalender Grundeinstellung wenn Zeitspanne bereits ausgewählt
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Und man hat eine Zeitspanne ausgewählt
    Wenn man einen in der Zeitspanne verfügbaren Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und das Startdatum entspricht dem vorausgewählten Startdatum
    Und das Enddatum entspricht dem vorausgewählten Enddatum

  @javascript
  Szenario: Kalender Grundeinstellung wenn Geräteparks bereits ausgewählt sind
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Und man die Geräteparks begrenzt
    Und man ein Modell welches über alle Geräteparks der begrenzten Liste beziehbar ist zur Bestellung hinzufügt
    Dann öffnet sich der Kalender
    Und es wird der alphabetisch erste Gerätepark ausgewählt der teil der begrenzten Geräteparks ist

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
    Dann werden die Schliesstage gemäss gewähltem Gerätepark angezeigt