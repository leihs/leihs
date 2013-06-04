# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

  Szenario: Modelllistenübersicht
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann sieht man die Explorative Suche
    Und man sieht die Modelle der ausgewählten Kategorie
    Und man sieht Sortiermöglichkeiten
    Und man sieht die Gerätepark-Auswahl
    Und man sieht die Einschränkungsmöglichkeit eines Ausleihzeitraums

  Szenario: Ein einzelner Modelllisteneintrag
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und einen einzelner Modelleintrag beinhaltet
    | Bild                 |
    | Modellname           |
    | Herstellname         |
    | Auswahl-Schaltfläche |

  Szenario: Modellliste scrollen
    Angenommen man ist "Normin"
    Und man sieht eine Modellliste die gescroll werden muss
    Wenn bis ans ende der bereits geladenen Modelle fährt
    Dann wird der nächste Block an Modellen geladen und angezeigt
    Wenn man bis zum Ende der Liste fährt
    Dann werden die weiteren Modelle geladen und angezeigt
    Und am ender der Liste wurden alle Modelle der ausgewählten Kategorie geladen und angezeigt

  Szenario: Modellliste sortieren
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Wenn man die Liste nach Modellname (alphabetisch aufsteigend) sortiert
    Dann ist die Liste nach Modellname (alphabetisch aufsteigend) sortiert
    Wenn man die Liste nach Modellname (alphabetisch absteigend) sortiert
    Dann ist die Liste nach Modellname (alphabetisch absteigend) sortiert
    Wenn man die Liste nach Herstellername (alphabetisch aufsteigend) sortiert
    Dann ist die Liste nach Herstellername (alphabetisch aufsteigend) sortiert
    Wenn man die Liste nach Herstellername (alphabetisch absteigend) sortiert
    Dann ist die Liste nach Herstellername (alphabetisch absteigend) sortiert

  Szenario: Ausleihezeitraum Standarteinstellung
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann ist kein Ausleihzeitraum ausgewählt

  Szenario: Ausleihezeitraum Startdatum wählen
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und man ein Startdatum auswählt
    Dann wird automatisch das Enddatum auf den folgenden Tag gesetzt
    Und die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind

  Szenario: Ausleihezeitraum Enddatum wählen
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und man ein Enddatum auswählt
    Dann wird automatisch das Startdatum auf den vorhergehenden Tag gesetzt
    Und die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind

  Szenario: Ausleihzeitraum löschen
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Und das Startdatum und Enddatum des Ausleihzeitraums sind ausgewählt
    Wenn man das Startdatum und Enddatum leert
    Dann wird die Lists nichtmehr nach Ausleihzeitraum gefilter

  Szenario: Ausleihzeitraum Datepicker
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Wenn man in das Startdatum oder Enddatum klickt
    Dann kann man einen Datepicker benutzen
