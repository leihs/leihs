Feature: Verification

  Background:
    Given I am Andi


  @personas @javascript @browser
  Scenario: Show inventory to group-manager
    When I open the Inventory
    Then for each visible model I can see the Timeline
    And I can export to a csv-file
    And I can search and filter
    But I can not edit models, items, options, software or licenses
    And I can not add models, items, options, software or licenses

  @personas @javascript
  Scenario: take-back in timeline not valid
    When I open the Inventory
    When I enter the timeline of a model with hand overs, take backs or pending orders
    And I click on a user's name
    Then there is no link to:
      | acknowledge |
      | hand over   |
      | take back   |

  @personas @javascript @browser
  Scenario: Overbooking in orders not possible for Group Managers in overview
    When I open a submitted order to be verified by a Group Manager
    And I add a model which leads to an overbooking
    Then I see an error message

  @personas @javascript @browser
  Scenario: Overbooking in orders not possible for Group Managers in calendar
    When I open a submitted order to be verified by a Group Manager
    And I open the booking calendar
    And I change the quantity of the model in the calendar which leads to an overbooking
    And I save the booking calendar
    Then I see an error message within the booking calendar

  @personas @javascript @browser
  Scenario: Overbooking in hand overs not possible for Group Managers in overview
    When I open a hand over editable by the Group Manager
    And I add a model which leads to an overbooking
    Then I see an error message

  @personas @javascript @browser
  Scenario: Overbooking in orders not possible for Group Managers in calendar
    When I open a hand over editable by the Group Manager
    And I open the booking calendar
    And I change the quantity of the model in the calendar which leads to an overbooking
    And I save the booking calendar
    Then I see an error message within the booking calendar
     