# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

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
