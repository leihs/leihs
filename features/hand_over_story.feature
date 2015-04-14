#Feature: Hand Over
#
#       As an Inventory Manager
#       I want to see all approved orders, grouped by customer,
#       in order to generate contracts and hand over the physical items
#
#Background:
#  Given a lending_manager for inventory pool 'ABC' logs in as 'inv_man_0'
#    And his password is 'pass'
#  # For full-stack steps:
#  Given inventory pool 'ABC'
#    And a inventory_manager 'inv_man_0' for inventory pool 'ABC'
#    And his password is 'pass'
#
#@old-ui
#Scenario: List approved orders, grouped by same customer and same start_date
#
#       Given 15 items of model 'NEC 245' exist
#         And 12 items of model 'BENQ 19' exist
#       Given the list of approved orders contains 0 elements
#       When 'Joe' places a new order
#               And he asks for 5 'NEC 245' from 31.3.2030
#               And he asks for 2 'BENQ 19' from 31.3.2030
#               And he submits the new order
#               And lending_manager approves the order
#               And lending_manager clicks on 'hand_over'
#       Then he sees 1 line with a total quantity of 7
#       When 'Joe' places a new order
#               And he asks for 2 'NEC 245' from 31.3.2030
#               And he asks for 1 'BENQ 19' from 31.3.2030
#               And he submits the new order
#               And lending_manager approves the order
#               And lending_manager clicks on 'hand_over'
#       Then he sees 1 line with a total quantity of 10
#@old-ui
#Scenario: List approved orders, grouped by different customers and different start_dates
#       Given 15 items of model 'NEC 245' exist
#         And 12 items of model 'BENQ 19' exist
#       Given the list of approved orders contains 0 elements
#       When 'Joe' places a new order
#               And he asks for 5 'NEC 245' from 31.3.2031
#               And he asks for 2 'BENQ 19' from 31.3.2031
#               And he asks for 4 'BENQ 19' from 12.12.2035
#               And he submits the new order
#               And lending_manager approves the order
#               And lending_manager clicks on 'hand_over'
#       Then he sees 2 lines with a total quantity of 11
#               And line 1 has a quantity of 7 for customer 'Joe'
#               And line 2 has a quantity of 4 for customer 'Joe'
#       When 'Jack' places a new order
#               And he asks for 2 'NEC 245' from 31.3.2030
#               And he asks for 1 'BENQ 19' from 31.3.2033
#               And he asks for 3 'NEC 245' from 31.3.2033
#               And he submits the new order
#               And lending_manager approves the order
#               And lending_manager clicks on 'hand_over'
#       Then he sees 4 lines with a total quantity of 17
#               And line 1 has a quantity of 2 for customer 'Jack'
#               And line 2 has a quantity of 7 for customer 'Joe'
#               And line 3 has a quantity of 4 for customer 'Jack'
#               And line 4 has a quantity of 4 for customer 'Joe'
#@old-ui
#Scenario: Generation of contract lines based on the approved order lines of a given customer
#
#       Given 15 items of model 'NEC 245' exist
#         And 12 items of model 'BENQ 19' exist
#       Given the list of approved orders contains 0 elements
#       When 'Joe' places a new order
#               And he asks for 2 'NEC 245' from 31.3.2031
#               And he asks for 1 'BENQ 19' from 31.3.2031
#               And he asks for 3 'BENQ 19' from 12.12.2035
#               And he submits the new order
#               And lending_manager approves the order
#       Then a new contract is generated
#       When lending_manager clicks on 'hand_over'
#       Then he sees 2 lines with a total quantity of 6
#       When lending_manager chooses one line
#       Then he sees 6 contract lines for all approved order lines
#@old-ui
#Scenario: Select order lines to hand over
#
#       Given 15 items of model 'NEC 245' exist
#         And 12 items of model 'BENQ 19' exist
#       Given the list of approved orders contains 0 elements
#       When 'Joe' places a new order
#               And he asks for 2 'NEC 245' from 31.3.2031
#               And he asks for 2 'BENQ 19' from 31.3.2031
#               And he submits the new order
#               And lending_manager approves the order
#               And lending_manager clicks on 'hand_over'
#       Then he sees 1 line with a total quantity of 4
#       When lending_manager chooses one line
#       Then a new contract is generated
#               And he sees 4 contract lines for all approved order lines
#      When he assigns items to the first 3 items
#      When he selects to hand over the first 3 items
#      And he clicks the button 'hand_over'
#
#@old-ui
#Scenario: Don't generate a new contract if all Items are handed over
#
#       Given item 'AV_NEC245_1' of model 'NEC 245' exists
#       Given the list of approved orders contains 0 elements
#       When 'Joe' places a new order
#               And he asks for 1 'NEC 245' from 31.3.2031
#               And he submits the new order
#               And lending_manager approves the order
#               And lending_manager clicks on 'hand_over'
#       Then he sees 1 line with a total quantity of 1
#       When he chooses Joe's visit
#         And he assigns 'AV_NEC245_1' to the first line
#         And he signs the contract
#       Then the total number of contracts is 1
#@old-ui
#Scenario: Bugfix: Don't allow handing over the same item twice
#
#       Given items 'AV_NEC245_1,AV_NEC245_2' of model 'NEC 245' exist
#        Given there are no contracts
#       Given there is only an order by 'Joe'
#               And it asks for 1 'NEC 245' from 31.3.2030
#               And the order was submitted
#               And lending_manager approves the order
#       Given there is an order by 'Toshi'
#               And it asks for 1 'NEC 245' from 31.3.2030
#               And the order was submitted
#               And lending_manager approves the order
#       When lending_manager clicks on 'hand_over'
#        And he chooses Joe's visit
#         And he assigns 'AV_NEC245_1' to the first line
#       When lending_manager clicks on 'hand_over'
#        And he chooses Toshi's visit
#       When he tries to assign 'AV_NEC245_1' to the first line
#       Then he should see a flash error
#
#@old-ui
#Scenario: Pre-set the 'from' and 'to' date of a new line before adding it via 'add model' button
#  Given items 'GUN1,GUN2.5,GUN33.33' of model 'Naked Gun' exist
#  Given there are no contracts
#  Given there is only an order by 'Frank Drebbin'
#    And it asks for 1 'Naked Gun' from 31.3.2030
#    And the order was submitted
#   When I log in as 'inv_man_0' with password 'pass'
#    And I press "Backend"
#    And I follow "ABC"
#    And I follow "Acknowledge"
#    And I choose "View and edit" for the order by "Frank Drebbin"
#    And I follow the sloppy link "Save \+ Approve"
#    #Then show me the page
#    # TODO: Capybara can't deal with the greybox we use, either switch
#    # to something that works (e.g. fancybox) or try to use the
#    # jQuery dialog instead.
#    #And I follow the sloppy link "Save \+ Approve" in the greybox
#    #And I follow "Hand Over"
#    #And I choose "Hand Over" for the order by "Frank Drebbin"
#    # TODO: Actually set a date and add something.
#
#
#@old-ui
#Scenario: Only automatically check items and options for hand over that have a time period starting today
#       Given items 'AV_SOUNDGARDEN_1,AV_SOUNDGARDEN_2' of model 'The Day I tried to live - Single' exist
#        Given there are no contracts
#       Given there is only an order by 'Joe'
#               And it asks for 1 'The Day I tried to live - Single' from today
#               And it asks for 1 'The Day I tried to live - Single' from 31.3.2030
#               And the order was submitted
#               And lending_manager approves the order
#       Given I am on the home page
#        When I fill in "login_user" with "inv_man_0"
#         And I fill in "login_password" with "pass"
#         And I press "Login"
#       When I go to "backend"
#        And I follow "Hand Over"
#       When I follow "Hand Over" within "list_table"
#        # TODO: the following line needs to be migrated to capybara:
#         And I fill in 1st of "line_item_inventory_code_" with "AV_SOUNDGARDEN_1"
#       Then the "contract_lines_" checkbox should be checked
#       #Then that should check that line since it's from this day on
#        When he assigns 'AV_SOUNDGARDEN_2' to line 1
#       Then that should not check that line since it's not from this day on
#       When he signs the contract
#       Then the contract should only contain the item 'AV_SOUNDGARDEN_1'
