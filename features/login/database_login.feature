Feature: Login through database authentication

  In order to login
  As a normal user
  I want to be able to login using a database authentication

  Background:
    Given personas existing
      And I am "Ramon"

  @javascript
  Scenario: Login through database authentication
     And I am logged out 
    When I visit the homepage
     And I login
    Then I am logged in
    