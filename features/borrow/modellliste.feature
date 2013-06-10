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

  Szenario: Geräteparkauswahl Standartwert
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann ist die Geräteparkauswahl nicht eingeschränkt
    Und es sind alle Geräteparks ausgewählt
    Und die Modellliste zeigt Modelle aller Geräteparks an
    Und im Filter steht "Alle Geräteparks"

  Szenario: Geräteparkauswahl Einzelauswählen
    Angenommen man ist "Normin"
    Und man beindet sich auf der Modellliste
    Wenn man ein bestimmten Gerätepark in der Geräteparkauswahl auswählt
    Dann sind alle anderen Geräteparks abgewählt
    Und die Modellliste zeigt nur Modelle dieses Geräteparks an
    Und die Auswahl klappt zu
    Und im Filter steht der Name des ausgewählten Geräteparks

  Szenario: Geräteparkauswahl Einzelabwahl
    Angenommen man ist "Normin"
    Und man beindet sich auf der Modellliste
    Wenn man einige Geräteparks abwählt
    Dann wird die Modellliste nach den übrig gebliebenen Geräteparks gefiltert
    Und die Auswahl klappt nocht nicht zu
    Und im Filter steht "Geräteparks eingegrenzt"

  Szenario: Geräteparkauswahl Einzelabwahl bis auf einen Gerätepark
    Angenommen man ist "Normin"
    Und man beindet sich auf der Modellliste
    Wenn man alle Geräteparks bis auf einen abwählt
    Dann wird die Modellliste nach dem übrig gebliebenen Gerätepark gefiltert
    Und die Auswahl klappt nocht nicht zu
    Und im Filter steht der Name des übriggebliebenen Geräteparks

  Szenario: Geräteparkauswahl kann nicht leer sein
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann kann man nicht alle Geräteparks in der Geräteparkauswahl abwählen

  Szenario: Geräteparkauswahl sortierung
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann ist die Geräteparkauswahl alphabetisch sortiert

  Szenario: Alles zurücksetzen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Und Filter sind ausgewählt
    Und die Schaltfläche "Alles zurücksetzen" ist aktivert
    Wenn man "Alles zurücksetzen" wählt
    Dann sind alle Geräteparks in der Geräteparkauswahl wieder ausgewählt
    Und der Ausleihezeitraum ist leer
    Und die Sortierung ist nach Modellnamen (aufsteigend)
    Und die Schaltfläche "Alles zurücksetzen" ist deaktiviert
    
  Szenario: Modell suchen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste 
    Wenn man ein Suchwort eingibt
    Dann werden die folgenden Parameter durchsucht Modellname, Hersteller
    Und diejenigen Modelle werden angezeigt, welche diesen Suchkritieren entsprechen
  

    
