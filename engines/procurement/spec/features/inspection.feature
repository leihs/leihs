Feature: Inspection (state-behaviour described in seperate feature-file)

  Background:
    Given the basic dataset is ready

  @inspection
  Scenario: What to see in section "Requests" as inspector
    Given I am Barbara
    And several requests exist for my groups
    When I navigate to the requests overview page
    Then the current budget period is selected
    And only my groups are selected
    And all organisations are selected
    And both priorities are selected
    And the state "In inspection" is not present
    And all states are selected
    And the search field is empty
    And the checkbox "Only show my own request" is not marked
    And I see the headers of the columns of the overview
    And I see the amount of requests listed
    And I see the current budget period
    And I see the requested amount per budget period
    And I see the requested amount per group of each budget period
    And I see the budget limits of all groups
    And I see the total of all ordered amounts of each group
    And I see the total of all ordered amounts of a budget period
    And I see the percentage of budget used compared to the budget limit of my group
    And I see when the requesting phase of this budget period ends
    And I see when the inspection phase of this budget period ends
    And only my groups are shown
    And for each request I see the following information
      | article name          |
      | name of the requester |
      | department            |
      | organisation          |
      | price                 |
      | requested amount      |
      | approved amount       |
      | order amount          |
      | total amount          |
      | priority              |
      | state                 |

  @inspection
  Scenario: Using the filters as inspector
    Given I am Barbara
    And templates for my group exist
    And following requests exist for the current budget period
      | quantity | user   |
      | 2        | myself |
      | 1        | Roger  |
    When I navigate to the requests overview page
    And I select "Only show my own requests"
    And I select the current budget period
    And I select all groups
    And I select all organisations
    And I select both priorities
    And I select all states
    And I leave the search string empty
    Then the list of requests is adjusted immediately
    And I see both my requests
    And I see the amount of requests which are listed is 2
    When I navigate to the templates page of my group
    And I navigate back to the request overview page
    Then the filter settings have not changed

  @inspection
  Scenario: Creating a request as inspector
    Given I am Barbara
    And a receiver exists
    And a point of delivery exists
    When I want to create a new request
    And I fill in the following fields
      | key                        | value  |
      | Article / Project          | random |
      | Article nr. / Producer nr. | random |
      | Supplier                   | random |
      | Motivation                 | random |
      | Price                      | random |
      | Requested quantity         | 3      |
      | Approved quantity          | 3      |
    Then the "Approved quantity" is copied to the field "Order quantity"
    And I fill in the following fields
      | key            | value |
      | Order quantity | 2     |

    And the ordered amount and the price are multiplied and the result is shown
    When I upload a file
    And I choose the name of a receiver
    And I choose the point of delivery
    And I choose the following priority value
      | High |
    And I choose the following replacement value
      | New |
    And the status is set to "New"
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database

  @inspection
  Scenario: Creating a request for another user
    Given I am Barbara
    When I navigate to the requests overview page
    And I press on the Userplus icon of a group I am inspecting
    Then I am navigated to the requester list
    When I pick a requester
    Then I am navigated to the new request form for the requester
    When I fill in all mandatory information
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database

  @inspection
  Scenario: Give Reason when Partially Excepting or Denying
    Given I am Barbara
    And a request with following data exist
      | key              | value   |
      | budget period    | current |
      | user             | Roger   |
      | requested amount | 2       |
    When I navigate to the requests form of Roger
    And I fill in the following fields
      | key               | value |
      | Approved quantity | 0     |
  #NW: in hands on tests, the empty inspection comment field of a piartially approved request was not marked red and the browser position was not on the right place
    Then the field "inspection comment" is marked red
    And I can not save the request
    When I fill in the following fields
      | key                | value  |
      | Inspection comment | random |

    And I click on save
    Then I see a success message
    And the status is set to "Denied"
    And the changes are saved successfully to the database
    When I delete the following fields
      | Inspection comment |
    And I fill in the following fields
      | key               | value |
      | Approved quantity | 1     |
    Then the field "inspection comment" is marked red
    And I can not save the request
    When I fill in the following fields
      | key                | value  |
      | Inspection comment | random |

    And I click on save
    Then I see a success message
    And the status is set to "Partially approved"
    And the changes are saved successfully to the database

  @inspection
  Scenario: Moving request to another budget period as inspector
    Given I am Barbara
    And the current budget period is in inspection phase
    And there is a future budget period
    And there is a budget period which has already ended
    And following requests exist for the current budget period
      | quantity | user  | group     |
      | 3        | Roger | inspected |
    When I navigate to the requests form of Roger
    Then I can not move any request to the old budget period
    When I move a request to the future budget period
    Then I see a success message
    And the changes are saved successfully to the database
    And I can not submit the data

  @inspection
  Scenario: Moving request as inspector to another group
    Given I am Barbara
    And several groups exist
    And the current budget period is in inspection phase
    And following requests exist for the current budget period
      | quantity | user  | group     |
      | 3        | Roger | inspected |
    When I navigate to the requests form of Roger
    And I move a request to the other group where I am not inspector
    Then I see a success message
    And the changes are saved successfully to the database
    And the following information is deleted from the request
      | Approved quantity  |
      | Order quantity     |
      | Inspection comment |
