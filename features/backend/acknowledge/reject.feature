Feature: Reject Order

  In order to reject orders
  As a Lending Manager
  I want to have functionalities on a submitted order line

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Reject an order on the daily view
    When I open the daily view
     And I reject an order
    Then I see a summary of that order
     And I can write a reason why I reject that order
    When I reject the order
    Then the order is rejected
