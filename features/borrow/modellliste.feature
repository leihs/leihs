# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

  @personas
  Szenario: Modelllistenübersicht
    Angenommen ich bin Normin
    Wenn man sich auf der Modellliste befindet
    Dann sieht man die Explorative Suche
    Und man sieht die Modelle der ausgewählten Kategorie
    Und man sieht Sortiermöglichkeiten
    Und man sieht die Gerätepark-Auswahl
    Und man sieht die Einschränkungsmöglichkeit eines Ausleihzeitraums

  @personas
  Szenario: Ein einzelner Modelllisteneintrag
    Angenommen ich bin Normin
    Wenn man sich auf der Modellliste befindet
    Und einen einzelner Modelleintrag beinhaltet
    | Bild                 |
    | Modellname           |
    | Herstellname         |
    | Auswahl-Schaltfläche |

  @javascript @browser @personas
  Szenario: Modellliste scrollen
    Angenommen ich bin Normin
    Und man sieht eine Modellliste die gescroll werden muss
    Wenn bis ans ende der bereits geladenen Modelle fährt
    Dann wird der nächste Block an Modellen geladen und angezeigt
    Wenn man bis zum Ende der Liste fährt
    Dann wurden alle Modelle der ausgewählten Kategorie geladen und angezeigt

  @javascript @personas
  Szenario: Modellliste sortieren
    Angenommen ich bin Normin
    Und man sich auf der Modellliste befindet
    Wenn man die Liste nach "Modellname (alphabetisch aufsteigend)" sortiert
    Dann ist die Liste nach "Modellname" "(alphabetisch aufsteigend)" sortiert
    Wenn man die Liste nach "Modellname (alphabetisch absteigend)" sortiert
    Dann ist die Liste nach "Modellname" "(alphabetisch absteigend)" sortiert
    Wenn man die Liste nach "Herstellername (alphabetisch aufsteigend)" sortiert
    Dann ist die Liste nach "Herstellername" "(alphabetisch aufsteigend)" sortiert
    Wenn man die Liste nach "Herstellername (alphabetisch absteigend)" sortiert
    Dann ist die Liste nach "Herstellername" "(alphabetisch absteigend)" sortiert

  @personas
  Szenario: Ausleihezeitraum Standarteinstellung
    Angenommen ich bin Normin
    Wenn man sich auf der Modellliste befindet
    Dann ist kein Ausleihzeitraum ausgewählt

  @javascript @personas
  Szenario: Geräteparkauswahl kann nicht leer sein
    Angenommen ich bin Normin
    Wenn man sich auf der Modellliste befindet
    Dann kann man nicht alle Geräteparks in der Geräteparkauswahl abwählen

  @personas
  Szenario: Geräteparkauswahl sortierung
    Angenommen ich bin Normin
    Wenn man sich auf der Modellliste befindet
    Dann ist die Geräteparkauswahl alphabetisch sortiert

  @javascript @browser @personas
  Szenario: Geräteparkauswahl "alle auswählen"
    Angenommen ich bin Normin
    Wenn man sich auf der Modellliste befindet
    Und man wählt alle Geräteparks bis auf einen ab
    Und man wählt "Alle Geräteparks"
    Dann sind alle Geräteparks wieder ausgewählt
    Und die Auswahl klappt noch nicht zu
    Und die Liste zeigt Modelle aller Geräteparks

  @javascript @personas
  Szenario: Geräteparkauswahl kann nicht leer sein
    Angenommen ich bin Normin
    Wenn man sich auf der Modellliste befindet
    Dann kann man nicht alle Geräteparks in der Geräteparkauswahl abwählen

  @javascript @personas @browser
  Szenario: Ausleihezeitraum Startdatum wählen
    Angenommen ich bin Petra
    Wenn man sich auf der Modellliste befindet die nicht verfügbare Modelle beinhaltet
    Und man ein Startdatum auswählt
    Dann wird automatisch das Enddatum auf den folgenden Tag gesetzt
    Und die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind

  @javascript @personas
  Szenario: Ausleihezeitraum Enddatum wählen
    Angenommen ich bin Petra
    Wenn man sich auf der Modellliste befindet die nicht verfügbare Modelle beinhaltet
    Und man ein Enddatum auswählt
    Dann wird automatisch das Startdatum auf den vorhergehenden Tag gesetzt
    Und die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind

  @javascript @personas
  Szenario: Ausleihzeitraum löschen
    Angenommen ich bin Petra
    Wenn man sich auf der Modellliste befindet die nicht verfügbare Modelle beinhaltet
    Und das Startdatum und Enddatum des Ausleihzeitraums sind ausgewählt
    Wenn man das Startdatum und Enddatum leert
    Dann wird die Liste nichtmehr nach Ausleihzeitraum gefiltert

  @javascript @personas
  Szenario: Ausleihzeitraum Datepicker
    Angenommen ich bin Normin
    Und man sich auf der Modellliste befindet
    Dann kann man für das Startdatum und für das Enddatum den Datepick benutzen

  @javascript @personas
  Szenario: Modell suchen
    Angenommen ich bin Normin
    Und man befindet sich auf der Modellliste 
    Wenn man ein Suchwort eingibt
    Dann werden diejenigen Modelle angezeigt, deren Name oder Hersteller dem Suchwort entsprechen

  @javascript @browser @personas
  Szenario: Hovern über Modellen
    Angenommen ich bin Normin
    Und es gibt ein Modell mit Bilder, Beschreibung und Eigenschaften
    Und man befindet sich auf der Modellliste mit diesem Modell
    Wenn man über das Modell hovered
    Dann werden zusätzliche Informationen angezeigt zu Modellname, Bilder, Beschreibung, Liste der Eigenschaften
    Und wenn ich den Kalendar für dieses Modell benutze
    Dann können die zusätzliche Informationen immer noch abgerufen werden

  @personas
  Szenario: Geräteparkauswahl Standartwert
    Angenommen ich bin Normin
    Wenn man sich auf der Modellliste befindet
    Dann sind alle Geräteparks ausgewählt
    Und die Modellliste zeigt Modelle aller Geräteparks an
    Und im Filter steht "Alle Geräteparks"

  @javascript @personas
  Szenario: Geräteparkauswahl Einzelauswählen
    Angenommen ich bin Normin
    Und man befindet sich auf der Modellliste
    Wenn man ein bestimmten Gerätepark in der Geräteparkauswahl auswählt
    Dann sind alle anderen Geräteparks abgewählt
    Und die Modellliste zeigt nur Modelle dieses Geräteparks an
    Und die Auswahl klappt noch nicht zu
    Und im Filter steht der Name des ausgewählten Geräteparks

  @javascript @personas
  Szenario: Geräteparkauswahl Einzelabwahl
    Angenommen ich bin Normin
    Und man befindet sich auf der Modellliste
    Wenn man einige Geräteparks abwählt
    Dann wird die Modellliste nach den übrig gebliebenen Geräteparks gefiltert
    Und die Auswahl klappt nocht nicht zu
    Und im Filter steht die Zahl der ausgewählten Geräteparks

  @javascript @personas
  Szenario: Geräteparkauswahl Einzelabwahl bis auf einen Gerätepark
    Angenommen ich bin Normin
    Und man befindet sich auf der Modellliste
    Wenn man alle Geräteparks bis auf einen abwählt
    Dann wird die Modellliste nach dem übrig gebliebenen Gerätepark gefiltert
    Und die Auswahl klappt nocht nicht zu
    Und im Filter steht der Name des übriggebliebenen Geräteparks

  @javascript @personas
  Szenario: Alles zurücksetzen
    Angenommen ich bin Normin
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

  @javascript @personas
  Szenario: Alles zurücksetzen verschwindet automatisch, wenn die Filter wieder auf die Starteinstellungen gesetzt werden
    Angenommen ich bin Normin
    Und man befindet sich auf der Modellliste
    Und Filter sind ausgewählt
    Und die Schaltfläche "Alles zurücksetzen" ist aktivert
    Wenn ich alle Filter manuell zurücksetze
    Dann verschwindet auch die "Alles zurücksetzen" Schaltfläche
