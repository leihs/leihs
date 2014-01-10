# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

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
  Szenario: Geräteparkauswahl kann nicht leer sein
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann kann man nicht alle Geräteparks in der Geräteparkauswahl abwählen
