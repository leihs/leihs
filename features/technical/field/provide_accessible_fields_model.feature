Feature: Provision of accessible fields

  Model test (class methods)

  Background:
    Given test data setup for =Provision of accessible fields= feature

  Scenario Outline: Accessible fields should be provided according to user's access level
    Given a user with role <a manager role> exists
    When you get the accessible fields for this user
    Then the user has access to at least all the fields without any permissions
    And the amount of the accessible fields <compared to> <an higher manager role> can be different

    Examples:
      Lower level should have less accessible fields than higher level

      | a manager role  | compared to   | an higher manager role |
      | lending_manager | less than     | inventory_manager      |
