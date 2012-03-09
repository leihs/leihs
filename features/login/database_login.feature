Feature: Login through database authentication

  In order to login
  As a normal user
  I want to be able to login using a database authentication

  Background: Load the personas
    Given personas are loaded
    Given I am "Ramon"
    
  @javascript
  Scenario: Login through database authentication
    When I visit the homepage
     And I login
    Then I am logged in
    