#Feature: Caching of availabilities
#
#       As a Developper
#       I want to be sure that once an Availability of some DocumentLine has been calculated
#       Then it should not be recalculated again on successive displays of the DocumentLine
#       When a DocumentLine is changed
#       Then all DocumentLines concerning the same InventoryPool and the same Model should drop their cached knowledge of the Models availability
#       When any of those DocumentLines is shown again
#       Then the caches of those DocumentLines should be recalculated
#
#
# Does not work due to completely new UI       
#@old-ui
#Scenario: Issue an Order
#
#       Given 1 inventory pool
#       And a model 'Coffee Mug' exists
#       And this model has 3 items in inventory pool 1
#       And customer 'joe' has access to inventory pool 1
#       Given there is an order by 'joe'
#       And it asks for 1 items of model 'Coffee Mug'
#       And a customer for inventory pool '1' logs in as 'joe'
#       When he checks his basket
#       Then the availability of the respective orderline should be cached
#       When he asks for another 1 items of model 'Coffee Mug'
#       Then the availability cache of both order lines should have been invalidated
#       When he checks his basket
#       Then the availability of all order lines should be cached
#       When he deletes the first line
#       Then the availability cache of all order lines should have been invalidated
#       When he checks his basket
#       Then the availability of all order lines should be cached
#
# Does not work due to completely new UI
#@old-ui
#Scenario: Don't influence other Orders
#
#       Given 1 inventory pool
#       And a model 'Coffee Mug' exists
#       And this model has 3 items in inventory pool 1
#       And customer 'Engelbart' has access to inventory pool 1
#       Given there is only an order by a customer named 'Engelbart'
#       And it asks for 1 items of model 'Coffee Mug'
#       And customer 'Toshi' has access to inventory pool 1
#       Given there is an order by 'Toshi'
#       And it asks for 1 items of model 'Coffee Mug'
#       When a customer for inventory pool '1' logs in as 'Engelbart'
#        And he checks his basket
#       Then the availability of the respective orderline should be cached
#       When a customer for inventory pool '1' logs in as 'Toshi'
#        And he checks his basket
#       Then the availability of all the order lines should be cached
#       When he deletes the first line
#       Then the availability cache of all order lines should have been invalidated
#       When a customer for inventory pool '1' logs in as 'Engelbart'
#       Then the availability of all the order lines should be cached
#
## Does not work due to completely new UI
#@old-ui
#Scenario: Manage a Contract
#
#       Given a lending_manager for inventory pool 'ABC' logs in as 'inv_man_0'
#       And a model 'Coffee Mug' exists
#       And this model has 4 items in inventory pool ABC
#       And customer 'Joe' has access to inventory pool ABC
#       And there is only an order by 'Joe'
#        And it asks for 2 items of model 'Coffee Mug'
#       When a customer for inventory pool 'ABC' logs in as 'Joe'
#        And he checks his basket
#       Then the availability of all order lines should be cached
#       When he submits the new order
#        And a lending_manager for inventory pool 'ABC' logs in as 'inv_man_0'
#        And the lending_manager clicks on 'acknowledge'
#       Then he sees 1 order
#        And the availability of all order lines should be cached
#       When he chooses Joe's order
#       Then Joe's order is shown
#        And the availability of all order lines should be cached
#       When lending_manager approves the order
#       Then the availability cache of all contract lines should have been invalidated
#       When lending_manager clicks on 'hand_over'
#        And lending_manager chooses one line
#       Then the availability of all contract lines should be cached

