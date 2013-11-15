# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden
  
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
    Wenn man über das Modell hovered
    Dann werden zusätzliche Informationen angezeigt zu Modellname, Bilder, Beschreibung, Liste der Eigenschaften
    Und wenn ich den Kalendar für dieses Modell benutze
    Dann können die zusätzliche Informationen immer noch abgerufen werden
