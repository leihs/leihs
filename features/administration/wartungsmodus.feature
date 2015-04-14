
Feature: Wartungsmodus

Als Administrator möchte ich die Möglichkeit haben,
für die Bereiche "Verwalten" und "Verleih" bei Wartungsarbeiten das System zu sperren und dem Benutzer eine Meldung anzuzeigen

  Background:
    Given I am Gino

  @javascript @personas
  Scenario: Disabling the manage section
    Given I am in the system-wide settings
    When I choose the function "Disable manage section"
    Then I have to enter a note
    When I enter a note for the "manage section"
    And I save
    Then the settings for the "manage section" were saved
    And the "manage section" is disabled for users
    And users see the note that was defined

  @javascript @personas
  Scenario: Disabling the borrow section
    Given I am in the system-wide settings
    When I choose the function "Disable borrow section"
    Then I have to enter a note
    When I enter a note for the "borrow section"
    And I save
    Then the settings for the "borrow section" were saved
    And the "borrow section" is disabled for users
    And users see the note that was defined

  @javascript @personas
  Scenario: Enabling the manage section
    Given the "manage section" is disabled
    And I am in the system-wide settings
    When I deselect the "disable manage section" option
    And I save
    Then the "manage section" is not disabled for users
    And the note entered for the "manage section" is still saved

  @javascript @personas
  Scenario: Enabling the borrow section
    Given the "borrow section" is disabled
    And I am in the system-wide settings
    When I deselect the "disable borrow section" option
    And I save
    Then the "borrow section" is not disabled for users
    And the note entered for the "borrow section" is still saved
