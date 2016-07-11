Feature: Model availability Timeline

  @javascript @browser @personas
  Scenario: Where is visible the timeline
    Given I am Mike
    When I open a contract for acknowledgement
    Then for each visible model I can see the Timeline
    When I open a hand over
    Then for each visible model I can see the Timeline
    When I open a take back
    Then for each visible model I can see the Timeline
    When I search for 'a'
    Then for each visible model I can see the Timeline
    When I open the inventory
    Then for each visible model I can see the Timeline

  @javascript @browser @personas @problematic
  Scenario: open timeline in pending orders as group-manager
    Given I am Andi
    When I open a contract for acknowledgement
    Then for each visible model I can see the Timeline

  @javascript @browser @personas
  Scenario: open timeline in hand-over as group-manager
    Given I am Andi
    When I open a hand over with models
    Then for each visible model I can see the Timeline
