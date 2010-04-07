Feature: Caching of availabilities

	As a Developper
	I want to be sure that once an Availability of some DocumentLine has been calculated
	Then it should not be recalculated again on successive displays of the DocumentLine
	When a DocumentLine is changed
	Then all DocumentLines concerning the same InventoryPool and the same Model
	     should drop their cached knowledge of the Models availability
	When any of those DocumentLines is shown again
	Then the caches of those DocumentLines should be recalculated
	
	
	
Scenario: Issue an Order
	
	Given 1 inventory pool
		And a model 'Coffee Mug' exists
		And this model has 3 items in inventory pool 1
		And user 'joe' has access to inventory pool 1
		And a new order is placed by a user named 'joe'
		And it asks for 1 items of model 'Coffee Mug'
		And a customer for inventory pool '1' logs in as 'joe'
	When he checks his basket
	Then the availability of the respective orderline should be cached
	When he asks for another 1 items of model 'Coffee Mug'
	Then the availability cache of both order lines should have been invalidated
	When he checks his basket
	Then the availability of all order lines should be cached
	When he deletes the first line
	Then the availability cache of all order lines should have been invalidated
	When he checks his basket
	Then the availability of all order lines should be cached


Scenario: Manage a Contract

	Given a manager for inventory pool 'ABC' logs in as 'inv_man_0'
		And a model 'Coffee Mug' exists
		And this model has 4 items in inventory pool ABC
		And user 'Joe' has access to inventory pool ABC
		And the list of new orders contains 0 elements
		And a new order is placed by a user named 'Joe'
		And it asks for 2 items of model 'Coffee Mug'
	When a customer for inventory pool 'ABC' logs in as 'Joe'
	 And he checks his basket
	Then the availability of all order lines should be cached
	When the new order is submitted
	 And a manager for inventory pool 'ABC' logs in as 'inv_man_0'
	 And the lending_manager clicks on 'acknowledge'
	Then he sees 1 order
	 And the availability of all order lines should be cached
	When he chooses Joe's order
	Then Joe's order is shown
	 And the availability of all order lines should be cached
	When lending_manager approves the order
	Then the availability cache of all contract lines should have been invalidated
	When lending_manager clicks on 'hand_over'
	 And lending_manager chooses one line
	Then the availability of all contract lines should be cached

