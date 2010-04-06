Feature: Caching of availabilities

	As a Developper
	I want to be sure that once an Availability of some DocumentLine has been calculated
	Then it should not be recalculated again on successive displays of the DocumentLine
	When a different DocumentLine with the same Model from the same InventoryPool is changed
	Then we need to forget our old knowledge of the Availability of all DocumentLines with the same Model and InventoryPool
	Then the Availablity will get recalculated upon the display of the Document line
	
	
	
Scenario: Add DocumentLine to a fresh Order
	
	Given 1 inventory pools
		And a model 'Coffee Mug' exists
		And this model has 2 items in inventory pool 1
		And user 'joe' has access to inventory pool 1
		And a new order is placed by a user named 'joe'
		And it asks for 1 items of model 'Coffee Mug'
		And a customer for inventory pool '1' logs in as 'joe'
	When he checks his basket
	Then the availability of the respective orderline should be cached
	
