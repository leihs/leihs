Feature: Fields controller

  Controller test

  @personas
  Scenario: Index action
    Given I log in as 'pius' with password 'password'
    When the fields in json format are fetched via the index action
    Then the accessible fields of the logged in user include each field from the json response
