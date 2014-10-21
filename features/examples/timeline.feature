Feature: Timeline der Modell-Verfügbarkeit

  @javascript @browser @personas
  Scenario: Wo man die Timeline sieht
    Given ich bin Mike 
    When ich eine Bestellung bearbeite
    Then kann ich für jedes sichtbare Model die Timeline anzeigen lassen
    When ich eine Aushändigung mache
    Then kann ich für jedes sichtbare Model die Timeline anzeigen lassen
    When ich eine Rücknahme mache
    Then kann ich für jedes sichtbare Model die Timeline anzeigen lassen
    When ich suche
    Then kann ich für jedes sichtbare Model die Timeline anzeigen lassen
    When man die Liste des Inventars öffnet
    Then kann ich für jedes sichtbare Model die Timeline anzeigen lassen

  @current @personas
  Scenario: open timeline in pending orders as group-manager
    Given I am Andi
    When I open a pending order 
    And this order contains a model
    Then I can open the timeline to this model
    
  @current @personas
  Scenario: open timeline in hand-over as group-manager
    Given I am Andi
    When I open a hand-over
    And this hand-over contains a model
    Then I can open the timeline to this model