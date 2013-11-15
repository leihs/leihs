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

    Dann werden die Schliesstage gemäss gewähltem Gerätepark angezeigt