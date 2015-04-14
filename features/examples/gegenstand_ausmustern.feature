Feature: Retire

  @javascript @personas
  Scenario Outline: Retire
    Given I am Matti
    And I pick a <object> that is in stock and that the current inventory pool is the owner of
    Then I can retire this <object> if I give a reason for retiring
    And the newly retired <object> immediately disappears from the inventory list
    Examples:
      | object  |
      | item    |
      | license |

  @javascript @personas
  Scenario Outline: Preventing retiring an object that isn't in stock
    Given I am Mike
    And I pick a <object> that is not in stock
    Then I cannot retire such a <object>
    Examples:
      | object  |
      | item    |
      | license |

  @javascript @personas
  Scenario Outline: Preventing retiring an object I'm not the owner of
    Given I am Matti
    And I pick a <object> the current inventory pool is not the owner of
    Then I cannot retire such a <object>
    Examples:
      | object     |
      | item |
      | license     |

  @javascript @personas
  Scenario Outline: Error when trying to retire without giving a reason
    Given I am Matti
    And I pick a <object> that is in stock and that the current inventory pool is the owner of
    And I don't give any reason for retiring this item
    And the <object> is not retired
    Examples:
      | object     |
      | item |
      | license     |

  @javascript @personas
  Scenario Outline: Unretiring an item
    Given I am Mike
    And I pick a retired <object> that the current inventory pool is the owner of
    And I am on this <object>'s edit page
    When I unretire this <object>
    And I fill in the supply category
    And I save
    Then I am redirected to the inventory list
    And this <object> is not retired
    Examples:
      | object     |
      | item |
      | license     |


  # Not really sure what this scenario is supposed to tell us. Why are we on
  # an edit page? We would end up on that page anyway after picking one
  # of those items, which is what we do explicitly in this scenario.
  @personas
  Scenario Outline: How retired items are displayed in a responsible department/inventory pool
    Given I am Mike
    And I pick a retired <object> that the current inventory pool is responsible for but not the owner of
    Then I am on this <object>'s edit page
    Examples:
      | object     |
      | item |
      | license     |
