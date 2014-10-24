Feature: Login through database authentication

  In order to login
  As a normal user
  I want to be able to login using a database authentication

  @personas
  Scenario: Login through database authentication
    Given I log out
    When I visit the homepage
    And I login as "Normin" via web interface
    Then I am logged in

  #80098490
  @personas @javascript
  Scenario: Changing my own password
    Given I am Normin
    And my authentication system is "DatabaseAuthentication"
    When I hover over my name
    And I view my user data
    And I change my password
    Then my password is changed