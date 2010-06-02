Feature: Hand Over

	As an Inventory Manager
	I want to see all approved orders, grouped by user,
	in order to generate contracts and hand over the physical items

	
Scenario: List approved orders, grouped by same user and same start_date

	Given a manager for inventory pool 'ABC' logs in as 'inv_man_0'
	Given a model 'NEC 245' exists
	  	And 15 items of model 'NEC 245' exist
		And a model 'BENQ 19' exists
	  	And 12 items of model 'BENQ 19' exist
	Given the list of approved orders contains 0 elements
	When 'Joe' places a new order
		And he asks for 5 'NEC 245' from 31.3.2100 
		And he asks for 2 'BENQ 19' from 31.3.2100 
		And he submits the new order
		And lending_manager approves the order
		And lending_manager clicks on 'hand_over'
	Then he sees 1 line with a total quantity of 7 
	When 'Joe' places a new order
		And he asks for 2 'NEC 245' from 31.3.2100 
		And he asks for 1 'BENQ 19' from 31.3.2100 
		And he submits the new order
		And lending_manager approves the order
		And lending_manager clicks on 'hand_over'
	Then he sees 1 line with a total quantity of 10 

Scenario: List approved orders, grouped by different users and different start_dates

	Given a manager for inventory pool 'ABC' logs in as 'inv_man_0'
	Given a model 'NEC 245' exists
	  	And 15 items of model 'NEC 245' exist
		And a model 'BENQ 19' exists
	  	And 12 items of model 'BENQ 19' exist
	Given the list of approved orders contains 0 elements
	When 'Joe' places a new order
		And he asks for 5 'NEC 245' from 31.3.2101 
		And he asks for 2 'BENQ 19' from 31.3.2101 
		And he asks for 4 'BENQ 19' from 12.12.2112
		And he submits the new order
		And lending_manager approves the order
		And lending_manager clicks on 'hand_over'
	Then he sees 2 lines with a total quantity of 11
		And line 1 has a quantity of 7 for user 'Joe' 
		And line 2 has a quantity of 4 for user 'Joe'
	When 'Jack' places a new order
		And he asks for 2 'NEC 245' from 31.3.2100 
		And he asks for 1 'BENQ 19' from 31.3.2111 
		And he asks for 3 'NEC 245' from 31.3.2111 
		And he submits the new order
		And lending_manager approves the order
		And lending_manager clicks on 'hand_over'
	Then he sees 4 lines with a total quantity of 17 
		And line 1 has a quantity of 2 for user 'Jack' 
		And line 2 has a quantity of 7 for user 'Joe' 
		And line 3 has a quantity of 4 for user 'Jack'
		And line 4 has a quantity of 4 for user 'Joe'
	
Scenario: Generation of contract lines based on the approved order lines of a given user

	Given a manager for inventory pool 'ABC' logs in as 'inv_man_0'
	Given a model 'NEC 245' exists
	  	And 15 items of model 'NEC 245' exist
		And a model 'BENQ 19' exists
	  	And 12 items of model 'BENQ 19' exist
	Given the list of approved orders contains 0 elements
	When 'Joe' places a new order
		And he asks for 2 'NEC 245' from 31.3.2101 
		And he asks for 1 'BENQ 19' from 31.3.2101 
		And he asks for 3 'BENQ 19' from 12.12.2112	
		And he submits the new order
		And lending_manager approves the order
	Then a new contract is generated
	When lending_manager clicks on 'hand_over'
	Then he sees 2 lines with a total quantity of 6
	When lending_manager chooses one line
	Then he sees 6 contract lines for all approved order lines

Scenario: Select order lines to hand over

	Given a manager for inventory pool 'ABC' logs in as 'inv_man_0'
	Given a model 'NEC 245' exists
	  	And 15 items of model 'NEC 245' exist
		And a model 'BENQ 19' exists
	  	And 12 items of model 'BENQ 19' exist
	Given the list of approved orders contains 0 elements
	When 'Joe' places a new order
		And he asks for 2 'NEC 245' from 31.3.2101 
		And he asks for 2 'BENQ 19' from 31.3.2101	
		And he submits the new order
		And lending_manager approves the order
		And lending_manager clicks on 'hand_over'
	Then he sees 1 line with a total quantity of 4
	When lending_manager chooses one line
	Then a new contract is generated
		And he sees 4 contract lines for all approved order lines
#temp#
#	When he assigns items to the first 3 items
#	When he selects to hand over the first 3 items
#	And he clicks the button 'hand_over'


Scenario: Don't generate a new contract if all Items are handed over

	Given a manager for inventory pool 'ABC' logs in as 'inv_man_0'
	Given a model 'NEC 245' exists
	  	And item 'AV_NEC245_1' of model 'NEC 245' exists
	Given the list of approved orders contains 0 elements
	When 'Joe' places a new order
		And he asks for 1 'NEC 245' from 31.3.2101 
		And he submits the new order
		And lending_manager approves the order
		And lending_manager clicks on 'hand_over'
	Then he sees 1 line with a total quantity of 1
	When he chooses Joe's visit
         And he assigns 'AV_NEC245_1' to the first line
         And he signs the contract
	Then the total number of contracts is 1

Scenario: Bugfix: Don't allow handing over the same item twice

	Given a manager for inventory pool 'ABC' logs in as 'inv_man_0'
	Given a model 'NEC 245' exists
	  	And items 'AV_NEC245_1,AV_NEC245_2' of model 'NEC 245' exist
        Given there are no orders and no contracts
	Given 'Joe' places a new order
		And he asks for 1 'NEC 245' from 31.3.2100 
		And he submits the new order
		And lending_manager approves the order
	Given 'Toshi' places a new order
		And he asks for 1 'NEC 245' from 31.3.2100
		And he submits the new order
		And lending_manager approves the order
	When lending_manager clicks on 'hand_over'
	 And he chooses Joe's visit
         And he assigns 'AV_NEC245_1' to the first line
	When lending_manager clicks on 'hand_over'
	 And he chooses Toshi's visit
	When he tries to assign 'AV_NEC245_1' to the first line
	Then he should see a flash error
