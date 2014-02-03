Feature: Availability of Models

	As an Inventory Manager 
	I want to know when things are available
	In order to make sure that reservations can be met

Background: As a Organisation we have some Inventory with things to lend out
  Given personas existing
    And inventory pool 'ABC'
    # this used the old UI -- we don't need to use any UI at all, so let's do the login more
    # directly as below
	  #And a lending_manager for inventory pool 'ABC' logs in as 'lending_manager'
    And a lending_manager for inventory pool 'ABC' is logged in as 'lending_manager'

Scenario: No reservations	
	Given 7 items of model 'NEC 245' exist
	  And 0 reservations exist for model 'NEC 245'
	 When lending_manager checks availability for 'NEC 245'
	 Then it should always be available

Scenario: With reservation
	Given 7 items of model 'NEC 245' exist
	  And a reservation exists for 3 'NEC 245' from 21.3.2030 to 31.3.2030
	  When lending_manager checks availability for 'NEC 245'
	  Then 7 should be available from now to 20.3.2030
	   And 4 should be available from 21.3.2030 to 31.3.2030
	   And 7 should be available from 1.4.2030 to the_end_of_time


Scenario: With mulitple reservations
	Given 7 items of model 'NEC 245' exist
	  And a reservation exists for 3 'NEC 245' from 21.3.2030 to 31.3.2030
	  And a reservation exists for 2 'NEC 245' from 10.3.2030 to 24.3.2030
	  And a reservation exists for 2 'NEC 245' from 23.3.2030 to 5.4.2030
	 When lending_manager checks availability for 'NEC 245'
	 Then 7 should be available from now to 9.3.2030
	  And 5 should be available from 10.3.2030 to 20.3.2030
	  And 2 should be available from 21.3.2030 to 22.3.2030
	  And 0 should be available from 23.3.2030 to 24.3.2030
	  And 2 should be available from 25.3.2030 to 31.3.2030
	  And 5 should be available from 1.4.2030 to 5.4.2030
	  And 7 should be available from 6.4.2030 to the_end_of_time

Scenario: With mulitple one day reservations of a model having one single item
	
	Given 1 items of model 'NEC 245' exist
	  And a reservation exists for 1 'NEC 245' from 21.3.2030 to 21.3.2030
	 When lending_manager checks availability for 'NEC 245'
	 Then 0 should be available from 21.3.2030 to 21.3.2030

Scenario: With mulitple one day reservations of a model having two items
	Given 2 items of model 'NEC 245' exist
	  And a reservation exists for 2 'NEC 245' from 21.3.2030 to 21.3.2030
	 When lending_manager checks availability for 'NEC 245'
	 Then 0 should be available from 21.3.2030 to 21.3.2030


Scenario: With Maintenance Day
	Given a model 'NEC 245' exists
	  And the maintenance period for this model is 4 days
	  And 7 items of that model exist
	  And a reservation exists for 3 'NEC 245' from 21.3.2030 to 31.3.2030
	  And a reservation exists for 2 'NEC 245' from 10.3.2030 to 24.3.2030
	 When lending_manager checks availability for 'NEC 245'
	 Then 7 should be available from now to 9.3.2030
	  And 5 should be available from 10.3.2030 to 20.3.2030
	  And 2 should be available from 21.3.2030 to 28.3.2030
	  And 4 should be available from 29.3.2030 to 4.4.2030
	  And 7 should be available from 5.4.2030 to the_end_of_time

Scenario: Maximum availabliltiy
	Given a model 'NEC 245' exists
	  And the maintenance period for this model is 4 days
	  And 7 items of that model exist
	  And a reservation exists for 3 'NEC 245' from 21.3.2030 to 31.3.2030
	 When lending_manager checks availability for 'NEC 245'
	 Then the maximum available quantity on 20.3.2030 is 7
	  And the maximum available quantity on 21.3.2030 is 4
	  And the maximum available quantity on 31.3.2030 is 4
	  And the maximum available quantity on 4.4.2030 is 4
	  And the maximum available quantity on 5.4.2030 is 7