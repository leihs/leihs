Feature: Close Contract

  In order to take back thins
  As a lending manager
  I want to be able to take back items and close a contract

  @javascript
  Scenario: Hand over a selection of items
    Given I am "Pius"
     When I open a hand over
      And I select an item line by assigning an inventory code
      And I click "Hand Over"
     Then I see a summary of the things I selected for hand over
     When I click "Hand Over"
     Then the contract is signed for the selected items
