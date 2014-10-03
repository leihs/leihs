# language: de

Funktionalität: Timeline der Modell-Verfügbarkeit

  @javascript @browser @personas
  Szenario: Wo man die Timeline sieht
    Angenommen ich bin Mike 
    Wenn ich eine Bestellung bearbeite
    Dann kann ich für jedes sichtbare Model die Timeline anzeigen lassen
    Wenn ich eine Aushändigung mache
    Dann kann ich für jedes sichtbare Model die Timeline anzeigen lassen
    Wenn ich eine Rücknahme mache
    Dann kann ich für jedes sichtbare Model die Timeline anzeigen lassen
    Wenn ich suche
    Dann kann ich für jedes sichtbare Model die Timeline anzeigen lassen
    Wenn man die Liste des Inventars öffnet
    Dann kann ich für jedes sichtbare Model die Timeline anzeigen lassen

  @current
  Scenario: open timeline in pending orders as group-manager
    Given I am Andi
    When I open a pending order 
    And this order contains a model
    Then I can open the timeline to this model
    
  @current
  Scenario: open timeline in hand-over as group-manager
    Given I am Andi
    When I open a hand-over
    And this hand-over contains a model
    Then I can open the timeline to this model