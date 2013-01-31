Feature: Item search

  Model test

  Scenario: Search in properties' fields
    Given there are some items
     When I search for a text not present anywhere
     Then there are no items found
     When I fetch a random item
      And I store some text as a value to some new property in this item
      And I search for the same text I stored
     Then there is one item found
      And the item found is the one with the new property
