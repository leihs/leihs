Feature: LDAP logins using the HSLU custom adapter

  Background: LDAP-HSLU is configured
    Given the LDAP-HSLU authentication system is enabled and configured
    And there are some inventory pools with automatic access enabled
    And an LDAP response object for HSLU is mocked
    And a group called "Video" exists


  @personas
  Scenario: Logging in via LDAP-HSLU as a normal user
    When I log in as HSLU-LDAP user "normal_user"
    Then a leihs user should exist for "normal_user"
    And the user "normal_user" should have HSLU-LDAP as an authentication system
    And the user "normal_user" should not have any admin privileges

  @personas
  Scenario: Logging in via LDAP-HSLU as admin user
    When I log in as HSLU-LDAP user "admin_user"
    Then a leihs user should exist for "admin_user"
    And the user "admin_user" should have HSLU-LDAP as an authentication system
    And the user "admin_user" should have admin privileges

  @personas
  Scenario: Logging in an LDAP-HSLU user with an alphanumeric unique id
    When I log in as HSLU-LDAP user "normal_user"
    Then the user "normal_user" should have a badge ID of "L9999"

  @personas
  Scenario: Logging in an LDAP-HSLU user with a numeric unique id
    When I log in as HSLU-LDAP user "numeric_unique_id_user"
    Then the user "numeric_unique_id_user" should have a badge ID of "L1234"
