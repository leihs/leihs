Feature: Approve anyway

  In order to approve an order
  As a Lending Manager
  I want to have functionalities to approve an order even if there are conflicts/problems

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Approve anyway on daily view
    Given I open the daily view
      And I try to approve an order that has problems
     Then I got an information that this order has problems
     When I approve anyway
     Then this order is approved
      