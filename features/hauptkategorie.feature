
Feature: Kategorien

  Scenario: Begriffsklärung Hauptkategorien
    Given es existiert eine Hauptkategorie
    Then kann diese Kategorie Kinder besitzen
    And sie selbst ist nicht Kinde irgendeiner anderen Kategorie
