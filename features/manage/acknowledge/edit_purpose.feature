Feature: Edit purpose during acknowledge process

  In order to edit a contracts purpose
  As an Lending Manager
  I want to have functionalities to change the purpose

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Change the purpose of a contract
     When I open a contract for acknowledgement
     Then I see the contract's purpose 
     When I change the contract's purpose
     Then the contract's purpose is changed
