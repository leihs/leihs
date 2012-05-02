Feature: Edit purpose during acknowledge process

  In order to edit an orders purpose
  As an Lending Manager
  I want to have functionalities to change the purpose

  @javascript
  Scenario: Change the purpose of an order
    Given I am "Pius"
     When I open an order for acknowledgement
     Then I see the order's purpose 
     When I change the order's purpose
     Then the order's purpose is changed