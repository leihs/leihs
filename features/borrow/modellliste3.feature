# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

  @javascript
  Szenario: Ausleihezeitraum Startdatum wählen
    Angenommen man ist "Petra"
    Wenn man sich auf der Modellliste befindet die nicht verfügbare Modelle beinhaltet
    Und man ein Startdatum auswählt
    Dann wird automatisch das Enddatum auf den folgenden Tag gesetzt
    Und die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind

  @javascript
  Szenario: Ausleihezeitraum Enddatum wählen
    Angenommen man ist "Petra"
    Wenn man sich auf der Modellliste befindet die nicht verfügbare Modelle beinhaltet
    Und man ein Enddatum auswählt
    Dann wird automatisch das Startdatum auf den vorhergehenden Tag gesetzt
    Und die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind

  @javascript
  Szenario: Ausleihzeitraum löschen
    Angenommen man ist "Petra"
    Wenn man sich auf der Modellliste befindet die nicht verfügbare Modelle beinhaltet
    Und das Startdatum und Enddatum des Ausleihzeitraums sind ausgewählt
    Wenn man das Startdatum und Enddatum leert
    Dann wird die Liste nichtmehr nach Ausleihzeitraum gefiltert

  @javascript
  Szenario: Ausleihzeitraum Datepicker
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Dann kann man für das Startdatum und für das Enddatum den Datepick benutzen