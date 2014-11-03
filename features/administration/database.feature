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

  @personas @javascript @browser
  Scenario: Check missing access rights
    When I visit "/admin/database/access_rights"
    Then all is correct
    When a database admin deletes some visit related access right records directly on the database
    Then the delete is not prevented
    When I visit "/admin/database/access_rights"
    Then there are missing customer access rights for upcoming actions
    When I restore the customer access rights
    Then all is correct
