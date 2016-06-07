
Feature: Redirect to login when not logged in

  As any user
  In order to perform actions inside the system with the proper privileges given to me
  I want to authenticate to the system so I can prove who I am

  @javascript @personas
  Scenario: Trying to perform an action without being logged in
    Given I am Pius
    And I try to perform an action in the manage area without being logged in
    Then I am redirected to the start page
    And I am notified that I am not logged in
