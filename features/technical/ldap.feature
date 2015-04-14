Feature: LDAP logins

  Background: LDAP is configured
    Given the LDAP authentication system is enabled and configured
    And there are some inventory pools with automatic access enabled

  @personas @ldap @manual
  Scenario: Logging in via LDAP as a normal user
    When I log in as LDAP user "normal_user"
    Then a leihs user should exist for "normal_user"
    And the user "normal_user" should have "LDAPAuthentication" as an authentication system
    And the user "normal_user" should not have any admin privileges

  @personas @ldap @manual
  Scenario: Logging in via LDAP as an admin
    When I log in as LDAP user "admin_user"
    Then a leihs user should exist for "admin_user"
    And the user "admin_user" should have "LDAPAuthentication" as an authentication system
    And the user "admin_user" should have admin privileges
