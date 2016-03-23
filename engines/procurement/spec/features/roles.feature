Feature: Description of roles

  @roles
  Scenario: Role Requester
    Given I am Roger
    And the basic dataset is ready
    And I navigate to procurement
    Then I can create a request for myself
    And I can edit my request
    And I can delete my request
    But I can not see the field "order quantity"
    And I can not see the field "approved quantity"
    And I can not see the field "inspection comment"
    And I can export the data
    And I can write an email to a group from the view of my request
    And I can move requests to other budget periods
    And I can move requests to other groups
    And I can not add requester
    And I can not add administrators
    And I can not add groups
    And I can not add budget periods
    And I can not manage templates
    And I can not create requests for another person
    And I can not see budget limits

  @roles
  Scenario: Role Inspector
    Given I am Anna
    And the basic dataset is ready
    And I navigate to procurement
    Then I can edit a request of group where I am an inspector
    And I can delete a request of group where I am an inspector
    And I can modify the field "order quantity" of other person's request
    And I can modify the field "approved quantity" of other person's request
    And I can modify the field "inspection comment" of other person's request
    And I can export the data
    And I can write an email to a group from the view of other's request
    And I can move requests of my own group to other budget periods
    And I can move requests of my own group to other groups
    And I can not create a request for myself
    And I can create requests for my group for another person
    And I can manage templates of my group
    And I can not add requester
    And I can not add administrators
    And I can not add groups
    And I can not add budget periods
    And I can see all budget limits

    @roles
    Scenario: Role Inspector and Requester
      Given I am Barbara
      And the basic dataset is ready
      And I navigate to procurement
      Then I can edit a request of group where I am an inspector
      And I can delete a request of group where I am an inspector
      And I can modify the field "order quantity" of other person's request
      And I can modify the field "approved quantity" of other person's request
      And I can modify the field "inspection comment" of other person's request
      And I can export the data
      And I can write an email to a group from the view of other's request
      And I can move requests of my own group to other budget periods
      And I can move requests of my own group to other groups
      And I can create a request for myself
      And I can create requests for my group for another person
      And I can manage templates of my group
      And I can not add requester
      And I can not add administrators
      And I can not add groups
      And I can not add budget periods
      And I can see all budget limits

  @roles
  Scenario: Role Administrator
    Given I am Hans Ueli
    And the basic dataset is ready
    And I navigate to procurement
    Then I can create a budget period
    And I can create a group
    And I can add requesters
    And I can add admins
    And I can read only the request of someone else
    And I can export the data
    And I can write an email to a group from the view of other's request
    And I can not create a request for myself
    And I can not create requests for another person
    And I can not manage templates

  @roles
  Scenario: Role leihs Admin
    Given I am Gino
    And I navigate to procurement
    Then I can assign the first admin of the procurement
