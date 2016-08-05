Feature: Inventory

       Describing Inventory Pools, Items, Models and Categories
       
  Scenario: Categories structure
       Given inventory pool 'ABC'
       And inventory pool short name 'ABC'
       Given a category 'Cameras' exists
       And a category 'Video Equipment' exists
       And a category 'Film' exists
       And a category 'Video' exists
       And a category 'Filters' exists
       And the category 'Film' is child of 'Cameras' with label 'Film'
       And the category 'Video' is child of 'Cameras' with label 'Video'
       And the category 'Video' is child of 'Video Equipment' with label 'Video Cameras'
       And the category 'Filters' is child of 'Video' with label 'Filters'
       When the category 'Cameras' is selected 
       Then there are 2 direct children and 3 total children
       And the label of the direct children are 'Film,Video'
       When the category 'Video Equipment' is selected 
       Then there are 1 direct children and 2 total children
       And the label of the direct children are 'Video Cameras'
       When the category 'Film' is selected    
       Then there are 0 direct children and 0 total children
       When the category 'Video' is selected   
       Then there are 1 direct children and 1 total children
       And the label of the direct children are 'Filters'
       When the category 'Filters' is selected 
       Then there are 0 direct children and 0 total children           

       
  Scenario: Models organized in categories
       Given inventory pool 'ABC'
       And inventory pool short name 'ABC'
       Given a category 'Cameras' exists
       And a category 'Video' exists
       And a model 'Sony 333' exists
       And the model 'Sony 333' belongs to the category 'Cameras'
       And a model 'Canon 444' exists
       And the model 'Canon 444' belongs to the category 'Cameras'
       And a model 'Beamer 123' exists
       And the model 'Beamer 123' belongs to the category 'Video'
       When the category 'Cameras' is selected 
       Then there are 2 models belonging to that category
       When the category 'Video' is selected   
       Then there are 1 models belonging to that category

#  @old-ui
#  Scenario: Tell the user if we can't create a new Package
#       Given inventory pool 'ABC'
#       And inventory pool short name 'ABC'
#       Given item 'P-ABC124' of model 'Book' exists
#       Given a inventory_manager for inventory pool 'ABC' logs in as 'inv_man_0'
#        # monkeypatch Item.proposed_inventory_code
#        When the broken alorithm proposes wrongly a duplicate inventory code 'ABC124'
#         And the lending_manager creates a new package
#        Then it will fail with an error
#        # un-monkeypatch Item.proposed_inventory_code
#         And we need to fix the algorithm again so subsequent tests won't fail


  Scenario Outline: What we want new generated inventory codes to look like
      Given inventory pool 'ABC'
      And inventory pool short name 'ABC'
      Given item '<inventory_code>' of model 'Trumpet' exists
      When leihs generates a new inventory code
      Then the generated_code should look like this '<result>'

      Examples:
       | inventory_code | result     |
       | 123            | ABC124     |
       | ABC127         | ABC128     |
       | 123ABC999      | ABC1000    |
       |                | ABC1       |
       | ABC2008012     | ABC2008013 |
       | ABC            | ABC1       |

  Scenario: Fill in holes in existing inventory code ranges when proposing new codes
      Given inventory pool 'ABC'
      And inventory pool short name 'ABC'
      Given a model 'Trumpet' exists
       And we have items with the following inventory_codes:
           | inventory_code |
           |          ABC02 |
           |          ABC03 |
           |          ABC06 |
           |          ABC07 |
           |          ABC10 |
           |          ABC11 |
       # we sleep one second, since mysql's datetime is only precise to a second
       # and thus subsequently created items wouldn't get sorted right
      When wait 1 seconds
       And we add an item 'ABC08'
       And leihs generates a new inventory code
      # first free inventory code after 'ABC08' is 'ABC9'
      Then the generated_code should look like this 'ABC9'
      When wait 1 seconds
       And we add an item 'ABC01'
       And leihs generates a new inventory code
      # first free inventory code after 'ABC01' is 'ABC4'
      Then the generated_code should look like this 'ABC4'

#  @old-ui
#  Scenario: Level 2 managers should only be able and allowed to assign items to their own pool
#      Given inventory pool 'ABC'
#      And inventory pool short name 'ABC'
#      Given a model 'Trumpet' exists
#       And a lending_manager 'George' for inventory pool 'ABC'
#       And his password is 'pass'
#      When I log in as 'George' with password 'pass'
#       And I press "Backend"
#       And I follow "Items (0)"
#       And I follow "New Item"
#       Then the item should only be assignable to the 'ABC' departement
#
#  @old-ui
#  Scenario: Level 3 managers should be able and allowed to assign items to whatever pool
#      Given inventory pool 'ABC'
#      And inventory pool short name 'ABC'
#       Given a model 'Trumpet' exists
#         And a inventory_manager 'George' for inventory pool 'ABC'
#         And his password is 'pass'
#        When I log in as 'George' with password 'pass'
#         And I press "Backend"
#         And I follow "Items (0)"
#         And I follow "New Item"
#         Then the item should be assignable to the 'None' departement
