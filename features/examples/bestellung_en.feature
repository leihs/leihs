Feature: Orders

  @upcoming
  Scenario: Acknowledge order
    Given a model 'NEC 245' exists
    And 7 items of that model exist
    And there is only an order by 'Joe'
    And it asks for 5 items of model 'NEC 245'
    And Joe's email address is joe@test.ch
    And the order was submitted
    When I go to the backend
    And I go to the lending section
    And I open the tab "orders"
    Then I see the order of Joe
    And I should be able to choose "Approve"
    And I should be able to choose "Edit"
    And I should be able to choose "Reject"
    When I click "Approve"
    Then the order is approved
    And joe@test.ch receives an email
    And its subject is '[leihs] Reservation Confirmation'
    And it contains information '5 NEC 245'
    And the lending manager should be able to choose "Hand over"

  @upcoming
  Scenario: Reject order
    Given I am Pius
    Given a model 'NEC 245' exists
    And 7 items of that model exist
    And there is only an order by 'Joe'
    And it asks for 5 items of model 'NEC 245'
    And Joe's email address is joe@test.ch
    And the order was submitted
    When I go to the backend
    And I go to the lending section
    And I open the tab "orders"
    Then I see the order of Joe
    When I click "Reject"
    Then I can enter a reason why the order is rejected
    When I click "Reject" on the comment frame
    Then the order is rejected
    And joe@test.ch receives an email
    And its subject is '[leihs] Reservation Rejected'
    And it contains information '5 NEC 245' and the reason, why the order was rejected
    And the status of the order changes to "Rejected"

