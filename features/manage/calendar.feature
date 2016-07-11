
Feature: Calendar view in the manage section

  Background:
    Given I am Pius

  @javascript @personas
  Scenario: Always show available quantity
    When I see the calendar
    Then I see the availability of models on weekdays as well as holidays and weekends

  @javascript @browser @personas @problematic
  Scenario: Overbooking in the booking calendar while editing an order
    Given I edit an order
     And I open the booking calendar
     Then there is no limit on augmenting the quantity, thus I can overbook
     And the order can be saved

  @javascript @browser @personas @problematic
  Scenario: Overbooking in the booking calendar during a hand over
    Given I am doing a hand over
     And I open the booking calendar
     Then there is no limit on augmenting the quantity, thus I can overbook
     And the hand over can be saved

  @personas @javascript @browser @problematic
  Scenario: Unavailable time spans
    Given I am doing a hand over
     And a model is no longer available
    When I select all reservations
     And I edit all reservations
    Then the list underneath the calendar shows the respective line as not available (red)
