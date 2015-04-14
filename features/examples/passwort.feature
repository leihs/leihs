
Feature: User passwords

  As inventory manager, lending manager or admin I want to be able to
  manage users' passwords, so that they can log in.

  @personas
  Scenario Outline: Creating a user with username and password
    Given I am <Person>
    And I am listing users
    When I have created a user with login "username" and password "password"
    And the user has access to an inventory pool
    Then the user "username" can log in with password "password"

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Chaging username and password
    Given I am <Person>
    And I am editing the user "Normin"
    When I change the username to "newnorminusername" and the password to "newnorminpassword"
    And the user has access to an inventory pool
    Then the user "newnorminusername" can log in with password "newnorminpassword"

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Creating a user with the wrong password confirmation
    Given I am <Person>
    And I am listing users
    When I try to create a user with a non-matching password confirmation
    Then I see an error message

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Trying to edit a user with missing password
    Given I am <Person>
    And I am editing the user "Normin"
    When I don't complete the password information and save
    Then I see an error message

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Creating a user without username
    Given I am <Person>
    And I am listing users
    When I try to create a user without username
    Then I see an error message

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Change password
    Given I am <Person>
    And I am editing the user "Normin"
    When I change the password for user "Normin" to "newnorminpassword"
    And the user has access to an inventory pool
    Then the user "Normin" can log in with password "newnorminpassword"

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Trying to create a user without a password
    Given I am <Person>
    And I am listing users
    When I try to create a user without a password
    Then I see an error message

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Editing user without username
    Given I am <Person>
    And I am editing the user "Normin"
    When I don't fill in a username and save
    Then I see an error message

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Editing user with wrong password confirmation
    Given I am <Person>
    And I am editing the user "Normin"
    When I fill in a wrong password confirmation and save
    Then I see an error message

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |

  @personas
  Scenario Outline: Chaging username
    Given I am <Person>
    And I am editing the user "Normin"
    When I change the username from "Normin" to "username"
    And the user has access to an inventory pool
    Then the user "username" can log in with password "password"

    Examples:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |
