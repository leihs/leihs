Feature: Login through database authentication

  In order to login
  As a normal user
  I want to be able to login using a database authentication

  Background:
    Given personas existing


  Scenario: Login through database authentication
   Given I log out
    When I visit the homepage
     And I login as "Normin" via web interface
    Then I am logged in
