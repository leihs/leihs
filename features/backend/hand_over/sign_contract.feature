Feature: Sign Contract

  In order to hand things over and sign a contract
  As a lending manager
  I want to be able to hand selected things over and generate a contract

  @javascript
  Scenario: Hand over a selection of items
    Given I am "Pius"
     When I open a hand over
      And I select some lines
      And I press "Hand Over"
     Then I see a summary of the things i selected for "hand over"
     When I press "Hand Over"
     Then the contract is signed
