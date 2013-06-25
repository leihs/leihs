# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

  Grundlage:
    Angenommen persona "Normin" existing

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

  @javascript
  Szenario: Modellliste scrollen
    Angenommen man ist "Normin"
    Und man sieht eine Modellliste die gescroll werden muss
    Wenn bis ans ende der bereits geladenen Modelle fährt
    Dann wird der nächste Block an Modellen geladen und angezeigt
    Wenn man bis zum Ende der Liste fährt
    Dann wurden alle Modelle der ausgewählten Kategorie geladen und angezeigt

  @javascript
  Szenario: Modellliste sortieren
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Wenn man die Liste nach "Modellname (alphabetisch aufsteigend)" sortiert
    Dann ist die Liste nach "Modellname" "(alphabetisch aufsteigend)" sortiert
    Wenn man die Liste nach "Modellname (alphabetisch absteigend)" sortiert
    Dann ist die Liste nach "Modellname" "(alphabetisch absteigend)" sortiert
    Wenn man die Liste nach "Herstellername (alphabetisch aufsteigend)" sortiert
    Dann ist die Liste nach "Herstellername" "(alphabetisch aufsteigend)" sortiert
    Wenn man die Liste nach "Herstellername (alphabetisch absteigend)" sortiert
    Dann ist die Liste nach "Herstellername" "(alphabetisch absteigend)" sortiert

  Szenario: Ausleihezeitraum Standarteinstellung
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann ist kein Ausleihzeitraum ausgewählt

  @javascript
  Szenario: Ausleihezeitraum Startdatum wählen
    Angenommen man ist "Petra"
    Wenn man sich auf der Modellliste befindet
    Und man ein Startdatum auswählt
    Dann wird automatisch das Enddatum auf den folgenden Tag gesetzt
    Und die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind

  @javascript
  Szenario: Ausleihezeitraum Enddatum wählen
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und man ein Enddatum auswählt
    Dann wird automatisch das Startdatum auf den vorhergehenden Tag gesetzt
    Und die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind

  @javascript
  Szenario: Ausleihzeitraum löschen
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Und das Startdatum und Enddatum des Ausleihzeitraums sind ausgewählt
    Wenn man das Startdatum und Enddatum leert
    Dann wird die Liste nichtmehr nach Ausleihzeitraum gefiltert

  @javascript
  Szenario: Ausleihzeitraum Datepicker
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Dann kann man für das Startdatum und für das Enddatum den Datepick benutzen

  Szenario: Geräteparkauswahl Standartwert
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann sind alle Geräteparks ausgewählt
    Und die Modellliste zeigt Modelle aller Geräteparks an
    Und im Filter steht "Alle Geräteparks"

  @javascript
  Szenario: Geräteparkauswahl Einzelauswählen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Wenn man ein bestimmten Gerätepark in der Geräteparkauswahl auswählt
    Dann sind alle anderen Geräteparks abgewählt
    Und die Modellliste zeigt nur Modelle dieses Geräteparks an
    Und die Auswahl klappt noch nicht zu
    Und im Filter steht der Name des ausgewählten Geräteparks

  @javascript
  Szenario: Geräteparkauswahl Einzelabwahl
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Wenn man einige Geräteparks abwählt
    Dann wird die Modellliste nach den übrig gebliebenen Geräteparks gefiltert
    Und die Auswahl klappt nocht nicht zu
    Und im Filter steht die Zahl der ausgewählten Geräteparks

  @javascript
  Szenario: Geräteparkauswahl Einzelabwahl bis auf einen Gerätepark
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Wenn man alle Geräteparks bis auf einen abwählt
    Dann wird die Modellliste nach dem übrig gebliebenen Gerätepark gefiltert
    Und die Auswahl klappt nocht nicht zu
    Und im Filter steht der Name des übriggebliebenen Geräteparks

  @javascript
  Szenario: Geräteparkauswahl kann nicht leer sein
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann kann man nicht alle Geräteparks in der Geräteparkauswahl abwählen

  Szenario: Geräteparkauswahl sortierung
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann ist die Geräteparkauswahl alphabetisch sortiert

  @javascript
  Szenario: Geräteparkauswahl "alle auswählen"
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und man wählt alle Geräteparks bis auf einen ab
    Und man wählt "Alle Geräteparks"
    Dann sind alle Geräteparks wieder ausgewählt
    Und die Auswahl klappt noch nicht zu
    Und die Liste zeigt Modelle aller Geräteparks

  @javascript
  Szenario: Alles zurücksetzen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Und Filter sind ausgewählt
    Und die Schaltfläche "Alles zurücksetzen" ist aktivert
    Wenn man "Alles zurücksetzen" wählt
    Dann sind alle Geräteparks in der Geräteparkauswahl wieder ausgewählt
    Und der Ausleihezeitraum ist leer
    Und die Sortierung ist nach Modellnamen (aufsteigend)
    Und das Suchfeld ist leer
    Und man sieht wieder die ungefilterte Liste der Modelle
    Und die Schaltfläche "Alles zurücksetzen" ist deaktiviert

  @javascript
  Szenario: Modell suchen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste 
    Wenn man ein Suchwort eingibt
    Dann werden diejenigen Modelle angezeigt, deren Name oder Hersteller dem Suchwort entsprechen

  @javascript
  Szenario: Hovern über Modellen
    Angenommen man ist "Normin"
    Und es gibt ein Modell mit Bilder, Beschreibung und Eigenschaften
    Und man befindet sich auf der Modellliste mit diesem Modell
    Wenn man über ein Modell hovered
    Dann werden folgende zusätzliche Informationen angezeigt Bilder, Beschreibung, Liste der Eigenschaften
