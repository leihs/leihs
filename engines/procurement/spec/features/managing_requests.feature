Feature: section Managing Requests

  Background:
    Given the basic dataset is ready

  @managing_requests
  Scenario: What to see in section "Requests" as requester only
    Given I am Roger
    And several requests created by myself exist
    When I navigate to the requests overview page
    Then the current budget period is selected
    And all groups in the filter groups are selected
    And both priorities are selected
    And the state "In inspection" is present
    And all states are selected
    And the search field is empty
    And I do not see the filter "Only show my own requests"
    And I see the headers of the columns of the overview
    And I see the amount of requests listed
    And I see the current budget period
    And I see the requested amount per budget period
    And I see the requested amount per group of each budget period
    And I see when the requesting phase of this budget period ends
    And I see when the inspection phase of this budget period ends
    And I see all groups
    And only my requests are shown
    And for each request I see the following information
      | article name          |
      | name of the requester |
      | department            |
      | organisation          |
      | price                 |
      | requested amount      |
      | total amount          |
      | priority              |
      | state                 |

  @managing_requests
  Scenario: Using the filters as requester only
    Given I am Roger
    And several requests created by myself exist
    When I navigate to the requests overview page
    Then I do not see the filter "Only show my own requests"
    When I select one or more budget periods
    And I select one or more groups
    And I select one ore both priorities
    And I select one or more states
    And I enter a search string
    Then the list of requests is adjusted immediately according to the filters chosen
    And the amount of requests found is shown

  @managing_requests
  Scenario: Creating a request as requester only
    Given I am Roger
    And several receivers exist
    And several points of delivery exist
    When I want to create a new request
    And I fill in the following fields
      | key                        | value  |
      | Article / Project          | random |
      | Article nr. / Producer nr. | random |
      | Supplier                   | random |
      | Motivation                 | random |
      | Price                      | random |
      | Requested quantity         | random |
    Then the amount and the price are multiplied and the result is shown
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

  @managing_requests
  Scenario Outline: Creating a request for a group
    Given I am <username>
    When I navigate to the requests overview page
    And I press on the plus icon of a group
    Then I am navigated to the new request form
    When I fill in the following fields
      | key                | value  |
      | Article / Project  | random |
      | Requested quantity | random |
      | Motivation         | random |
      | Replacement / New  | random |
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: Creating a request through a budget period selecting a template article
    Given I am <username>
    And several template categories exist
    And several template articles in categories exist
    When I navigate to the requests overview page
    And I press on the plus icon of the budget period
    Then I am navigated to the templates overview
    And I see the budget period
    And I see when the requesting phase of this budget period ends
    And I see when the inspection phase of this budget period ends
    And I see all categories of all groups listed
    When I press on a category
    Then I see all template articles of this category
    When I choose a template article
    Then I am navigated to the template request form of the specific group
    When I fill in all mandatory information
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: Creating a request through a budget period selecting a group
    Given I am <username>
    When I navigate to the requests overview page
    And I select "Only show my own requests" if present
    And I press on the plus icon of the budget period
    Then I am navigated to the templates overview
    And I see all groups listed
    When I choose a group
    Then I am navigated to the new request form of the specific group
    When I fill in all mandatory information
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: Creating a freetext request inside the new request page
    Given I am <username>
    And I am on the new request form of a group
    When I press on the plus icon on the left sidebar
    Then a new request line is added
    When I fill in all mandatory information
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario: Creating a request from a group template inside the new request page as inspector
    Given I am Barbara
    And several template categories exist
    And several template articles in categories exist
    And each template article contains
      | Article nr. / Producer nr. |
      | Supplier                   |
      | Item price                 |
    When I navigate to the templates overview
    And I press on a category
    And I choose a template article
    Then I am navigated to the template request form of the specific group
    And the following template data are prefilled
      | Article / Project          |
      | Article nr. / Producer nr. |
      | Supplier                   |
      | Item price                 |
    And no option is chosen yet for the field Replacement / New
    And I fill in the following fields
      | key                        | value  |
      | Motivation                 | random |
    And I choose the following replacement value
      | New |
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database

  @managing_requests
  Scenario: Creating a request from a group template inside the new request page as requester
    Given I am Roger
    And several template categories exist
    And several template articles in categories exist
    And each template article contains
      | Article nr. / Producer nr. |
      | Supplier                   |
      | Item price                 |
    When I navigate to the templates overview
    And I press on a category
    And I choose a template article
    Then I am navigated to the template request form of the specific group
    And the following template data are displayed as read-only
      | Article / Project          |
      | Article nr. / Producer nr. |
      | Supplier                   |
      | Item price                 |
    And no option is chosen yet for the field Replacement / New
    And I fill in the following fields
      | key                        | value  |
      | Motivation                 | random |
    And I choose the following replacement value
      | New |
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database

  @managing_requests
  Scenario Outline: Inserting an already inserted template article
    Given I am <username>
    And a request containing a template article exists
    When I navigate to the requests form of myself
    And I click on the template article which has already been added to the request
    Then I am navigated to the request containing this template article
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario: Changing an inserted template article
    Given I am Barbara
    And a request containing a template article exists
    And the template article contains an articlenr./suppliernr.
    When I navigate to the requests form of myself
    And I fill in the following fields
      | key                        | value  |
      | Article / Project          | random |
      | Article nr. / Producer nr. | random |
    When I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database
    And the template id is nullified in the database

  @managing_requests
  Scenario Outline: Request deleted because no information entered
    Given I am <username>
    When I navigate to the requests overview page
    And I press on the plus icon of a group
    Then I am navigated to the new request form
    When I type the first character in a field of the request form
    Then the following fields are mandatory and marked red
      | article            |
      | requested quantity |
      | motivation         |
      | new/replacement    |
    And the field where I have typed the character is not marked red
    When I delete this character
    Then all fields turn white
    When I click on save
    Then the line is deleted
    And no information is saved to the database
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: sorting requests
    Given I am <username>
    And several requests created by myself exist
    When I navigate to the requests overview page
    And I select all groups
    And I sort the requests by "<field>"
    Then the data is shown in the according sort order
    Examples:
      | username | field            |
      | Barbara  | article name     |
      | Barbara  | requester        |
      | Barbara  | organisation     |
      | Barbara  | price            |
      | Barbara  | quantity         |
      | Barbara  | the total amount |
      | Barbara  | priority         |
      | Barbara  | state            |
      | Roger    | article name     |
      | Roger    | requester        |
      | Roger    | organisation     |
      | Roger    | price            |
      | Roger    | quantity         |
      | Roger    | the total amount |
      | Roger    | priority         |
      | Roger    | state            |

  @managing_requests
  Scenario Outline: Delete a Request
    Given I am <username>
    And the current date has not yet reached the inspection start date
    And a request with following data exist
      | key           | value   |
      | budget period | current |
      | user          | myself  |
    When I navigate to the requests overview page
    And I select all budget periods
    And I select all groups
    And I open the request
    And I delete the request
    Then I receive a message asking me if I am sure I want to delete the data
    When I click on choice <choice>
    Then the request is "<result>" in the database
    Examples:
      | username | choice | result               |
      | Barbara  | yes    | successfully deleted |
      | Barbara  | no     | not deleted          |
      | Roger    | yes    | successfully deleted |
      | Roger    | no     | not deleted          |

  @managing_requests
  Scenario Outline: Modify a Request
    Given I am <username>
    And several requests created by myself exist
    And the current date has not yet reached the inspection start date
    Then I can modify my request
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: Choosing an existing or non existing Model
    Given I am <username>
    And several models exist
    When I navigate to the requests form of myself
    When I press on the plus icon on the left sidebar
    When I search an existing model by typing the article name
    And I choose the article from the suggested list
    Then the model name is copied into the article name field
    When I search a non existing model by typing the article name
    Then no search result is found
    When I fill in all mandatory information
    And I click on save
    Then the entered article name is saved
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario: Moving request to another budget period as requester only
    Given I am Roger
    And several budget periods exist
    And several requests created by myself exist
    And the current date has not yet reached the inspection start date
    And there is a future budget period
    When I navigate to the requests form of myself
    And I move a request to the future budget period
    And I see a success message
    And the changes are saved successfully to the database

  @managing_requests
  Scenario: Moving request to another group as requester only
    Given I am Roger
    And several groups exist
    And several requests created by myself exist
    And the current date has not yet reached the inspection start date
    When I navigate to the requests form of myself
    And I move a request to the other group
    Then I see a success message
    And the changes are saved successfully to the database

  @managing_requests
  Scenario Outline: Priority values
    Given I am <username>
    When I want to create a new request
    Then the priority value "Normal" is set by default
    And I can choose the following priority values
      | High   |
      | Normal |
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: Delete an attachment
    Given I am <username>
    And a request with following data exist
      | key           | value   |
      | budget period | current |
      | user          | myself  |
    And the request includes an attachment
    When I navigate to the requests form of myself
    And I delete the attachment
    And I click on save
    Then I see a success message
    And the attachment is deleted successfully from the database
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: Download an attachment
    Given I am <username>
    And a request with following data exist
      | key           | value   |
      | budget period | current |
      | user          | myself  |
    And the request includes an attachment
    When I navigate to the requests form of myself
    And I download the attachment
    Then the file is downloaded
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: View an attachment .jpg
    Given I am <username>
    And a request with following data exist
      | key           | value   |
      | budget period | current |
      | user          | myself  |
    And the request includes an attachment with the attribute .jpg
    When I navigate to the requests form of myself
    And I click on the attachment thumbnail
    Then the content of the file is shown in a viewer
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: View an attachment .pdf
    Given I am <username>
    And a request with following data exist
      | key           | value   |
      | budget period | current |
      | user          | myself  |
    And the request includes an attachment with the attribute .pdf
    When I navigate to the requests form of myself
    And I download the attachment
    Then the content of the file is shown in a viewer
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario Outline: Send an email to a group
    Given I am <username>
    And an email for a group exists
    When I navigate to the requests form of myself
    And I click on the email icon
    Then the email program is opened
    And the receiver of the email is the email of the group
    And the subject of the email is "Frage zum Beschaffungsantrag"
    And the group name is placed in paranthesis at the end of the subject
    Examples:
      | username |
      | Barbara  |
      | Roger    |

  @managing_requests
  Scenario: Additional Fields shown to requester only after budget period has ended
    Given I am Roger
    And a request with following data exist
      | key                | value   |
      | budget period      | current |
      | user               | myself  |
      | requested amount   | 2       |
      | approved amount    | 2       |
      | inspection comment | random  |
    And the budget period has ended
    When I navigate to the requests overview page
    And for each request I see the following information
      | requested amount |
      | approved amount  |
    When I open the request
    And I see the following request information
      | approved amount    |
      | inspection comment |
