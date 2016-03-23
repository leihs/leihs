Feature: Exporting the data to a CSV-File

  Background:
    Given the basic dataset is ready

  @csv
  Scenario Outline: Export data
    Given I am <username>
    And following requests exist for the current budget period
      | quantity | user    |
      | 2        | Barbara |
      | 3        | Roger   |
    When I navigate to the requests overview page
    And I export the shown information
    Then the following fields are exported
      | Budget period              |
      | Group                      |
      | Requester                  |
      | Organisation unit          |
      | Article / Project          |
      | Article nr. / Producer nr. |
      | Replacement / New          |
      | Requested quantity         |
      | Approved quantity          |
      | Order quantity             |
      | Price                      |
      | Total                      |
      | Priority                   |
      | Motivation                 |
      | Supplier                   |
      | Inspection comment         |
      | Receiver                   |
      | Point of Delivery          |
      | State                      |
    Examples:
      | username  |
      | Barbara   |
      | Roger     |
      | Hans Ueli |
