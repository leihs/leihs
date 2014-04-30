Feature: Login

  In order to login
  As a normal user
  I want to be able to login

  Background:
    Given personas existing


  Scenario: Redirection after successful login
    When I login as "Ramon" via web interface
    Then I am redirected to the "Admin" section
    And I log out
    When I login as "Mike" via web interface
    Then I am redirected to the "Inventory" section
    And I log out
    When I login as "Pius" via web interface
    Then I am redirected to the "Lending" section
    And I log out
