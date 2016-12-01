Feature: Exporting the data to a CSV-File

  Background:
    Given the basic dataset is ready

  @csv
  Scenario Outline: Export data for inspectors and admins
    Given I am <username>
    And all the existing requests are removed from the database
    And following requests exist for the current budget period
      | quantity | user    |
      | 2        | Barbara |
      | 3        | Roger   |
    When I navigate to the requests overview page
    And I export the shown information
    Then the following fields are exported
      | Budget period              |
      | Main category              |
      | Subcategory                |
      | Requester                  |
      | Department                 |
      | Organisation               |
      | Article or Project         |
      | Article nr. or Producer nr.|
      | Replacement / New          |
      | Requested quantity         |
      | Approved quantity          |
      | Order quantity             |
      | Price                      |
      | Total                      |
      | Priority                   |
      | Inspector's priority       |
      | Motivation                 |
      | Supplier                   |
      | Inspection comment         |
      | Receiver                   |
      | Point of Delivery          |
      | State                      |
    Examples:
      | username  |
      | Barbara   |
      | Hans Ueli |

  @csv
  Scenario: Export data for requesters
    Given I am Roger
    And all the existing requests are removed from the database
    And following requests with all values filled in exist for the current budget period
      | quantity | user    |
      | 3        | Roger   |
    When I navigate to the requests overview page
    And I export the shown information
    Then the following fields are exported
      | Budget period              |
      | Main category              |
      | Subcategory                |
      | Requester                  |
      | Department                 |
      | Organisation               |
      | Article or Project         |
      | Article nr. or Producer nr.|
      | Replacement / New          |
      | Requested quantity         |
      | Price                      |
      | Total                      |
      | Priority                   |
      | Motivation                 |
      | Supplier                   |
      | Receiver                   |
      | Point of Delivery          |
      | State                      |
    And the values for the following fields are not exported
      | Approved quantity          |
      | Order quantity             |
      | Inspector's priority       |
      | Inspection comment         |

  @csv
  Scenario: Export data for requesters for past budget period
    Given I am Roger
    And all the existing requests are removed from the database
    And following requests with all values filled in exist for the current budget period
      | quantity | user    |
      | 3        | Roger   |
    When I navigate to the requests overview page
    And I export the shown information
    Then the following fields are exported
      | Budget period              |
      | Main category              |
      | Subcategory                |
      | Requester                  |
      | Department                 |
      | Organisation               |
      | Article or Project         |
      | Article nr. or Producer nr.|
      | Replacement / New          |
      | Requested quantity         |
      | Price                      |
      | Total                      |
      | Priority                   |
      | Motivation                 |
      | Supplier                   |
      | Receiver                   |
      | Point of Delivery          |
      | State                      |
      | Approved quantity          |
      | Inspection comment         |
    And the values for the following fields are not exported
      | Approved quantity          |
      | Order quantity             |
      | Inspector's priority       |
      | Inspection comment         |

  @csv
  Scenario: Export data as Excel native format
    Given I am Roger
    When I navigate to the requests overview page
    Then I see the excel export button
