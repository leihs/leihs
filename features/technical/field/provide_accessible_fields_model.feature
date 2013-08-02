Feature: Provision of accessible fields

  Model test (class methods)

  Background:
    Given test data setup for =Provision of accessible fields= feature

  Scenario Outline: Accessible fields should be provided according to user's access level
    Given an user with role manager and <an access level> exists
    When you get the accessible fields for this user
    Then the user has access to at least all the fields without any permissions
    And the amount of the accessible fields <compared to> <an higher access level> can be different

    Examples:
      Lower level should have less accessible fields than higher level
      Except for level 1, where it's the same as for level 2 (leihs 3.0 drops level 1 and treats it as level 2)

      | an access level | compared to              | an higher access level |
      | 1               | equals                   | 2                      |
      | 2               | less than or equal to    | 3                      |
