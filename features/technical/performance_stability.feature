Feature: Leihs must perform acceptably for its users

  We want to make sure that performance of leihs does not degrade as leihs evolves.

  @personas
  Scenario: Computing availability of a heavily booked model should remain acceptable
    Given I am Mike
    Given the model "Kamera Nikon X12" exists
    And it has at least 500 items in the current inventory pool
    And it has at least 3 group partitions in the current inventory pool
    And it has at least 100 unsubmitted reservations in the current inventory pool
    And it has at least 100 submitted reservations in the current inventory pool
    And it has at least 100 approved reservations in the current inventory pool
    And it has at least 100 signed reservations in the current inventory pool
    When its availability is recalculate
    Then it should take maximum 0.5 seconds

  Scenario: Approve an order with a lot of reservations should remain acceptable
    Given the huge dump is loaded
    Then approve each submitted contract with more than 100 reservations should take maximum 2.0 seconds

  Scenario: Approvable check on single reservation
    Given the huge dump is loaded
    Then approvable check on single approvable reservation should take maximum 0.6 seconds

  Scenario: Availability check on single reservation
    Given the huge dump is loaded
    Then availability check on single submitted reservation should take maximum 1.0 seconds
