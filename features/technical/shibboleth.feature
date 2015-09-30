Feature: Shibboleth logins

  Background: Shibboleth is configured
    Given the Shibboleth authentication system is enabled and configured
    And there are some inventory pools with automatic access enabled

  @personas
  Scenario: Logging in via Shibboleth as a normal user
    When I log in as Shibboleth user "normal_user"
    Then a leihs user should exist for "normal_user"
    And the user "normal_user" should have "ShibbolethAuthentication" as an authentication system
    And the user "normal_user" should not have any admin privileges

  @personas
  Scenario: Logging in via Shibboleth as an admin
    When I log in as Shibboleth user "admin_user"
    Then a leihs user should exist for "admin_user"
    And the user "admin_user" should have "ShibbolethAuthentication" as an authentication system
    And the user "admin_user" should have admin privileges

  Scenario: Rejecting an invalid or incomplete configuration file
    When a Shibboleth configuration file with missing "unique_id_field" setting is used
    Then the missing field "unique_id_field" should raise an error
    When a Shibboleth configuration file with missing "firstname_field" setting is used
    Then the missing field "firstname_field" should raise an error
    When a Shibboleth configuration file with missing "lastname_field" setting is used
    Then the missing field "lastname_field" should raise an error
    When a Shibboleth configuration file with missing "mail_field" setting is used
    Then the missing field "mail_field" should raise an error
    When a complete Shibboleth configuration file is used
    Then the Shibboleth authentication controller should not raise any errors
