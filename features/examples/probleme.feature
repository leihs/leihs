
Feature: Displaying problems

  Background:
    Given I am Pius

  @javascript @browser @personas
  Scenario: Showing problems in an order when a model is not avaiable
    #Given ich editiere eine Bestellung die nicht in der Vergangenheit liegt
    Given I edit an order
    And a model is no longer available
    Then I see any problems displayed on the relevant lines
     And the problem is displayed as: "Nicht verfügbar 2(3)/7"
     And "2" are available for the user, also counting availability from groups the user is member of
     And "3" are available in total, also counting availability from groups the user is not member of
     And "7" are in this inventory pool (and borrowable)

  @javascript @browser @personas
  Scenario: Showing problems in an order when taking back a defective item
    Given I take back an item
    And one item is defective
     Then the affected item's line shows the item's problems
     And the problem is displayed as: "Gegenstand ist defekt"

  @javascript @personas
  Scenario: Showing problems when handing over a defective item
    Given I am doing a hand over
    And one item is defective
     Then the affected item's line shows the item's problems
     And the problem is displayed as: "Gegenstand ist defekt"

  @javascript @browser @personas
  Scenario: Displaying problems with incomplete items during take back
    Given I take back an item
     And one item is incomplete
     Then the affected item's line shows the item's problems
     And the problem is displayed as: "Gegenstand ist unvollständig"

  @javascript @personas
  Scenario: Showing problems when handing over an item that is not borrowable
    Given I am doing a hand over
    And one item is not borrowable
     Then the affected item's line shows the item's problems
     And the problem is displayed as: "Gegenstand nicht ausleihbar"

  @javascript @browser @personas
  Scenario: Showing problems when taking back an item that is not borrowable
    Given I take back an item
    And one item is not borrowable
    Then the affected item's line shows the item's problems
    And the problem is displayed as: "Gegenstand nicht ausleihbar"

  @personas @javascript @browser
  Scenario: Showing problems when item is not available while handing over
    Given I am doing a hand over
      And a model is no longer available
     Then I see any problems displayed on the relevant lines
      And the problem is displayed as: "Nicht verfügbar 2(3)/7"
      And "2" are available for the user, also counting availability from groups the user is member of
      And "3" are available in total, also counting availability from groups the user is not member of
      And "7" are in this inventory pool (and borrowable)

  @personas @javascript @browser
  Scenario: Showing problems when item is not available while taking back
    Given I open a take back, not overdue
     And a model is no longer available
     Then I see any problems displayed on the relevant lines
      And the problem is displayed as: "Nicht verfügbar 2(3)/7"
      And "2" are available for the user, also counting availability from groups the user is member of
      And "3" are available in total, also counting availability from groups the user is not member of
      And "7" are in this inventory pool (and borrowable)

  @javascript @personas
  Scenario: Problemanzeige bei Aushändigung wenn Gegenstand unvollständig
    Given I am doing a hand over
    And one item is incomplete
    Then the affected item's line shows the item's problems
    And the problem is displayed as: "Gegenstand ist unvollständig"

  @javascript @personas
  Scenario: Showing problems during take back if overdue
    Given I take back a late item
    Then the affected item's line shows the item's problems
    And the problem is displayed as: "Überfällig seit 6 Tagen"
