#Feature: A admin can search and sort various things in leihs
#
#       As an admin I want to be able to search things in leihs and to sort them
#
#  #Background: We have a user and various tables
#    #Given inventory pool 'ABC'
#      #And a inventory_manager 'inv_man_0' for inventory pool 'ABC'
#      #And his password is 'pass'
#      #And I log in as 'inv_man_0' with password 'pass'
#      #And I press "Backend"
#
#   @old-ui
#  Scenario: Search and sort customers
#   Given a customer "Customer B" exists
#     And a customer "Customer A" exists
#    When I follow "Users"
#     And I sort by "Full name"
#    Then "Customer A" should appear before "Customer B"
#    Then I go to logout
#
#   @old-ui
#  Scenario: Search and sort items
#   Given an item 'Item A' of model 'Model A' exists
#     And an item 'Item B' of model 'Model B' exists
#    When I follow "Items"
#     And I sort by "Inventory Code"
#    Then "Item A" should appear before "Item B"
#    Then I go to logout
#
#   @old-ui
#  Scenario: Search and sort locations
#   Given a location in building 'Building A' room 'Room F' and shelf 'Shelf X' exists
#     # we're only listing locations that offer items to lend
#     And at that location resides an item 'Item A' of model 'Model A'
#   Given a location in building 'Building B' room 'Room E' and shelf 'Shelf Y' exists
#     And at that location resides an item 'Item B' of model 'Model B'
#    When I follow "Locations"
#     And I sort by "Room"
#    Then "Room E" should appear before "Room F"
#    When I sort by "Shelf"
#    Then "Shelf X" should appear before "Shelf Y"
#    When I sort by "Building"
#    Then "Building A" should appear before "Building B"
#    Then I go to logout
#
#   @old-ui
#  Scenario Outline: Search unsortable things
#   Given a <kind> '<instance_name> A' exists
#     And a <kind> '<instance_name> B' exists
#    When I follow "<link_name>"
#    Then "<instance_name> A" should appear before "<instance_name> B"
#    Then I go to logout
#
#        Examples:
#          | kind     | instance_name | link_name  |
#          | group    | Group         | Groups     |
#          | model    | Model         | All Models |
#          | category | Category      | Categories |
#          | package  | Package       | Packages   |
