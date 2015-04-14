#Feature: Acknowledge orders
#
#       As an Inventory Manager
#       I want to see all new orders and acknowledge them
#       in order to have control over who is receiving what
#
#
# Need to comment this background so it doesn't get run -- backgrounds don't support
# tags like @old-ui
#Background:
#       Given I log in as a inventory_manager for inventory pool 'ABC'
#
# Does not work due to completely new UI /  (gibts bereits)
#@old-ui       @delete
#Scenario: List with new orders
#
#       Given there is only an order by 'Joe'
#         And the order was submitted
#        When I go to the backend
#         And I follow "Acknowledge"
#        Then I see 1 order
#         And the order was placed by a customer named 'Joe'
#
#
# Does not work due to completely new UI /  (gibts bereits)
#@old-ui @delete
#Scenario: Count of new orders is shown
#
#       Given there are only 5 orders
#       When lending_manager looks at the screen
#        When I go to the backend
#         And I follow "Acknowledge"
#       Then I see the 'Acknowledge' list
#
# Does not work due to completely new UI /  (created szenario: bestellungen)
#@old-ui @delete
#Scenario: Acknowledge order
#
#       Given a model 'NEC 245' exists
#         And 7 items of that model exist
#         And there is only an order by 'Joe'
#         And it asks for 5 items of model 'NEC 245'
#         And Joe's email address is joe@test.ch
#         And the order was submitted
#        When I go to the backend
#         And I follow "Acknowledge"
#       Then I see 1 order
#       When I choose to process Joe's order
#       Then Joe's order is shown
#        And I should see "Save + Approve"
#        And I should see "Reject Order"
#       When I click "Save + Approve"
#       Then show me the page
#       Then joe@test.ch receives an email
#        And its subject is '[leihs] Reservation Confirmation'
#        And it contains information '5 NEC 245'
#        And lending_manager sees 0 orders
#
# Does not work due to completely new UI /  (created szenario: bestellungen)
#@old-ui @delete
#Scenario: Reject order
#
#       Given a model 'NEC 245' exists
#         And 7 items of that model exist
#         And there is only an order by 'Joe'
#         And it asks for 5 items of model 'NEC 245'
#         And Joe's email address is joe@test.ch
#         And the order was submitted
#       When the lending_manager clicks on 'acknowledge'
#       Then he sees 1 order
#       When he chooses Joe's order
#       Then Joe's order is shown
#        And lending_manager can "Save + Approve"
#        And lending_manager can "Reject Order"
#       When lending_manager rejects order with reason 'Because I don't like you.'
#       Then joe@test.ch receives an email
#        And its subject is '[leihs] Reservation Rejected'
#        And it contains information 'Because I don't like you.'
#        And lending_manager sees 0 order
#
# Does not work due to completely new UI /  (gibts bereits)
#@old-ui @delete
#Scenario: Change amount and add Item
#
#       Given a model 'NEC 245' exists
#         And 7 items of that model exist
#         And a model 'NEC 333' exists
#         And 5 items of that model exist
#         And there is an order by 'Joe'
#         And it asks for 5 items of model 'NEC 245'
#         And Joe's email address is joe@test.ch
#         And the order was submitted
#       When the lending_manager clicks on 'acknowledge'
#        And he chooses Joe's order
#       Then Joe's order is shown
#       When lending_manager changes number of items of model 'NEC 245' to 4
#        And he adds 1 item 'NEC 333'
#        And he adds a personal message: 'NEC 333 is better in that situation'
#        And lending_manager approves order
#       Then lending_manager sees 0 order
#        And joe@test.ch receives an email
#        And its subject is '[leihs] Reservation confirmed (with changes)'
#        And it contains information '4 NEC 245'
#        And it contains information '1 NEC 333'
#        And it contains information 'Changed quantity for NEC 245 from 5 to 4'
#        And it contains information 'Added 1 NEC 333'
#        And it contains information 'NEC 333 is better in that situation'
#
# Does not work due to completely new UI /  (gibts bereits)
#@old-ui @delete
#Scenario: Increase amount beyond the number of available Items
#
#       Given a model 'NEC 245' exists
#         And one item of that model exists
#         And there is an order by 'Joe'
#         And it asks for 1 items of model 'NEC 245'
#         And the order was submitted
#       When the lending_manager clicks on 'acknowledge'
#        And he chooses Joe's order
#       Then Joe's order is shown
#       When lending_manager changes number of items of model 'NEC 245' to 2
#       Then all 'NEC 245' order lines are marked as invalid
#
# Does not work due to completely new UI /  (Ticket für dieses neue Feature erstellt)
#@old-ui @delete
#Scenario: Swap Model
#
#       Given a model 'NEC 245' exists
#         And 7 items of that model exist
#         And a model 'NEC 333' exists
#         And 5 items of that model exist
#         And there is an order by 'Joe'
#         And it asks for 5 items of model 'NEC 245'
#         And Joe's email address is joe@test.ch
#         And the order was submitted
#       When the lending_manager clicks on 'acknowledge'
#        And he chooses Joe's order
#       Then Joe's order is shown
#       When he chooses 'swap' on order line 'NEC 245'
#       Then Swap Item screen opens
#       When lending_manager searches for 'NEC 333'
#       Then a choice of 1 item appears
#       When lending_manager selects 'NEC 333'
#       Then he sees 5 items of model 'NEC 333'
#       When he adds a personal message: 'NEC 333 is better than NEC 245'
#        And lending_manager approves order
#       Then joe@test.ch receives an email
#        And its subject is '[leihs] Reservation confirmed (with changes)'
#        And it contains information '5 NEC 333'
#        And it contains information 'Swapped NEC 245 for NEC 333'
#        And it contains information 'NEC 333 is better than NEC 245'

