Feature: Login through database authentication

  In order to login
  As a normal user
  I want to be able to login using a database authentication

  @javascript
  Scenario: Login through database authentication
   Given I am "Ramon"
     And I am logged out 
    When I visit the homepage
     And I login
    Then I am logged in
    