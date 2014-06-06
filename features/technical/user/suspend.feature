Feature: Suspend all users

  Model test (instance methods)

  @personas
  Scenario: Suspend all users with late take backs
    Given there are at least 2 users with late take backs from at least 2 inventory pools where automatic suspension is activated
    When the cronjob executes the rake task for reminding and suspending all late users
    Then every such user is suspended until '1.1.2099' in the corresponding inventory pool
    And the suspended reason is the one configured for the corresponding inventory pool
