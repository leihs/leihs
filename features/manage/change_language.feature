
Feature: Changing interface language 

  In order to understand what the software is telling me
  As any user
  I want to switch the interface language to a language I know

  @personas
  Scenario: Changing my interface language
    Given I am Mike
    And I see the language list
    When I change the language to "English (US)"
    Then the language is "English (US)"

  @personas
  Scenario: Changing the language as normal user
    Given I am Normin
    And I am listing models
    When I change the language to "English (UK)"
    Then the language is "English (UK)"
    When I change the language to "Deutsch"
    Then the language is "Deutsch"
