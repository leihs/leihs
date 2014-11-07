Feature: create a software license

  In order to create a software license
  As an Inventory Manager
  I want to have functionalities to create a software license

  Given I am Mike

  @upcoming
  Scenario: create Software license with maintenance value with 2 decimal
    Given a software product exists
    When I add a new software license
    And I enter all mandatory fields
    And I type the amount "1200" into the field "maintenance amount"
    And I save the software license
    Then the "maintenance value" is saved as "1'200.00"