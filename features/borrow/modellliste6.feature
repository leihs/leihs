# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

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
  Szenario: Alles zurücksetzen verschwindet automatisch, wenn die Filter wieder auf die Starteinstellungen gesetzt werden
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Und Filter sind ausgewählt
    Und die Schaltfläche "Alles zurücksetzen" ist aktivert
    Wenn ich alle Filter manuell zurücksetze
    Dann verschwindet auch die "Alles zurücksetzen" Schaltfläche
