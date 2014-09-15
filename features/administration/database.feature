Feature: Database

  Background:
    Given I am Gino

  @personas
  Scenario: Check indexes
    When I visit "/admin/database/indexes"
    Then all is correct

  @personas
  Scenario: Check data consistency
    When I visit "/admin/database/consistency"
    Then all is correct
    When a database admin deletes some referenced records directly on the database
    Then the delete is prevented
    When I visit "/admin/database/consistency"
    Then all is correct

  @personas
  Scenario: Check empty columns
    When I visit "/admin/database/empty_columns"
    Then all is correct

