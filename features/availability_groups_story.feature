Feature: Availability of Models with Groups

	As an Inventory Manager 
	I want to know when things are available
	In order to make sure that reservations can be met


Background: As a Organisation we have some Inventory with things to lend out
	Given inventory pool 'AVZ'


Scenario: No Reservations
	
	Given 7 items of model 'NEC 245' exist
	 When 0 reservations exist for model 'NEC 245'
         Then 7 items of that Model should be available in Group 'General'
          And that Model should not be available in any other Group
	
# see also groups_unit.feature for some partial work

#Scenario: With Reservation
#	
#	Given 7 items of model 'NEC 245' exist
#	  	And a reservation exists for 3 'NEC 245' from 21.3.2100 to 31.3.2100
#	When lending_manager checks availability for 'NEC 245'
#	Then 7 should be available from now to 20.3.2100
#		And 4 should be available from 21.3.2100 to 31.3.2100
#		And 7 should be available from 1.4.2100 to the_end_of_time
#	
#Scenario: With mulitple reservations
#	
#	Given 7 items of model 'NEC 245' exist
#	  	And a reservation exists for 3 'NEC 245' from 21.3.2100 to 31.3.2100
#	  	And a reservation exists for 2 'NEC 245' from 10.3.2100 to 24.3.2100
#	  	And a reservation exists for 2 'NEC 245' from 23.3.2100 to 5.4.2100
#	When lending_manager checks availability for 'NEC 245'
#	Then 7 should be available from now to 9.3.2100
#		And 5 should be available from 10.3.2100 to 20.3.2100
#		And 2 should be available from 21.3.2100 to 22.3.2100
#		And 0 should be available from 23.3.2100 to 24.3.2100
#		And 2 should be available from 25.3.2100 to 31.3.2100
#		And 5 should be available from 1.4.2100 to 5.4.2100
#		And 7 should be available from 6.4.2100 to the_end_of_time
#	
#Scenario: With mulitple one day reservations of a model having one single item
#	
#	Given 1 items of model 'NEC 245' exist
#	  	And a reservation exists for 1 'NEC 245' from 21.3.2100 to 21.3.2100
#	When lending_manager checks availability for 'NEC 245'
#	Then 0 should be available from 21.3.2100 to 21.3.2100
#
#Scenario: With mulitple one day reservations of a model having two items
#	
#	Given 2 items of model 'NEC 245' exist
#	  	And a reservation exists for 2 'NEC 245' from 21.3.2100 to 21.3.2100
#	When lending_manager checks availability for 'NEC 245'
#	Then 0 should be available from 21.3.2100 to 21.3.2100
#
#Scenario: With Maintenance Day
#	
#	Given a model 'NEC 245' exists
#		And the maintenance period for this model is 4 days
#		And 7 items of model 'NEC 245' exist
#		And a reservation exists for 3 'NEC 245' from 21.3.2100 to 31.3.2100
#		And a reservation exists for 2 'NEC 245' from 10.3.2100 to 24.3.2100
#	When lending_manager checks availability for 'NEC 245'
#	Then 7 should be available from now to 9.3.2100
#		And 5 should be available from 10.3.2100 to 20.3.2100
#		And 2 should be available from 21.3.2100 to 28.3.2100
#		And 4 should be available from 29.3.2100 to 4.4.2100
#		And 7 should be available from 5.4.2100 to the_end_of_time
#	
#Scenario: Maximum availabliltiy
#	
#	Given a model 'NEC 245' exists
#		And the maintenance period for this model is 4 days
#		And 7 items of model 'NEC 245' exist
#		And a reservation exists for 3 'NEC 245' from 21.3.2100 to 31.3.2100
#	When lending_manager checks availability for 'NEC 245'
#	Then the maximum available quantity on 20.3.2100 is 7
#		And the maximum available quantity on 21.3.2100 is 4
#		And the maximum available quantity on 31.3.2100 is 4
#		And the maximum available quantity on 4.4.2100 is 4
#		And the maximum available quantity on 5.4.2100 is 7
#
#Scenario: In Repair
#	
#	Given 7 items of model 'NEC 245' exist
#		And a reservation exists for 3 'NEC 245' from 21.3.2100 to 31.3.2100
#		And lending_manager marks 1 'NEC 245' as 'in-repair' on 18.3.2100
#	When lending_manager checks availability for 'NEC 245'
#	Then the maximum available quantity on 20.3.2100 is 6
#		And the maximum available quantity on 21.3.2100 is 3
#
#Scenario: Not Returned
#	
#	Given 1 items of model 'Lasersword Grendab' exist
#		And a contract exists for 1 'Lasersword Grendab' from 1.1.2100 to 5.1.2100
#	When lending_manager checks availability for 'Lasersword Grendab'
#	Then if I check the maximum available quantity for 8.1.2100 it is 1 on 4.1.2100
#	Then if I check the maximum available quantity for 8.1.2100 it is 1 on 6.1.2100
#	Given the lending_manager signs the contract
#	When lending_manager checks availability for 'Lasersword Grendab'
#	Then if I check the maximum available quantity for 8.1.2100 it is 1 on 4.1.2100
#	Then if I check the maximum available quantity for 8.1.2100 it is 0 on 6.1.2100
#	
#	
#Scenario: Reservations from the past
#	
#	Given 3 items of model 'Lasersword Grendab' exist
#		And the maintenance period for this model is 2 days
#		And a reservation exists for 1 'Lasersword Grendab' from 1.1.1999 to 5.10.2100
#	When lending_manager checks availability for 'Lasersword Grendab' on 6.1.2100
#	Then the maximum available quantity on 8.1.2100 is 2
#		And the maximum available quantity on 15.2.2222 is 3
#	
#Scenario: Availability for a period of time
#	
#	Given 3 items of model 'Lasersword Grendab' exist
#		And a reservation exists for 1 'Lasersword Grendab' from 17.1.2100 to 27.2.2100
#	When lending_manager checks availability for 'Lasersword Grendab'
#	Then the maximum available quantity from 16.1.2100 to 28.2.2100 is 2
#		And the maximum available quantity from 10.1.2100 to 16.1.2100 is 3
#		And the maximum available quantity from 10.1.2100 to 17.1.2100 is 2
#		And the maximum available quantity from 19.1.2100 to 22.1.2100 is 2
#		And the maximum available quantity from 22.2.2100 to 1.3.2100 is 2
#		And the maximum available quantity from 27.2.2100 to 1.3.2100 is 2
#		And the maximum available quantity from 28.2.2100 to 5.4.2100 is 3
#	
#Scenario: Availability for a period - complicated
#	
#	Given 3 items of model 'Lasersword Grendab' exist
#		And a reservation exists for 1 'Lasersword Grendab' from 17.1.2100 to 27.2.2100
#		And a reservation exists for 1 'Lasersword Grendab' from 20.1.2100 to 5.2.2100
#		And a reservation exists for 1 'Lasersword Grendab' from 1.2.2100 to 9.3.2100
#	When lending_manager checks availability for 'Lasersword Grendab'
#	Then the maximum available quantity from 10.1.2100 to 16.1.2100 is 3
#		And the maximum available quantity from 17.1.2100 to 28.2.2100 is 0
#		And the maximum available quantity from 17.1.2100 to 31.1.2100 is 1
#		And the maximum available quantity from 1.2.2100 to 5.2.2100 is 0
#		And the maximum available quantity from 6.2.2100 to 15.3.2100 is 1
#		And the maximum available quantity from 28.2.2100 to 31.3.2100 is 2
#		And the maximum available quantity from 6.1.2100 to 1.2.2100 is 0
#
#Scenario: Availability for privileged customers
#
#	Given 3 items of model 'Lasersword Grendab' exist
#		And 2 items of this model are for 'Special' customers only
#		And User 'Regular Joe' is a 'Customer' customer
#		And User 'King Charles' is a 'Special' customer
#	When Regular Joe checks availability for 'Lasersword Grendab'
#	Then the maximum available quantity on 8.1.2100 is 1
#	When King Charles checks availability for 'Lasersword Grendab'
#	Then the maximum available quantity on 8.1.2100 is 3
#	Given a reservation exists for 1 'Lasersword Grendab' from 1.1.2100 to 27.2.2100
#	When Regular Joe checks availability for 'Lasersword Grendab'
#	Then the maximum available quantity on 8.1.2100 is 0
#	When King Charles checks availability for 'Lasersword Grendab'
#	Then the maximum available quantity on 8.1.2100 is 2
#	
#Scenario: A reservation of a single day should be blocking
#	Given reported by HKB on 1.June 2010 as #225
#	Given 1 item of model 'RepRap' exist
#		And a reservation exists for 1 'RepRap' from 17.1.2100 to 17.1.2100
#	When lending_manager checks availability for 'RepRap'
#	Then the maximum available quantity from 15.1.2100 to 20.1.2100 is 0
#		And the maximum available quantity from 15.1.2100 to 16.1.2100 is 1
#		And the maximum available quantity from 16.1.2100 to 17.1.2100 is 0
#		And the maximum available quantity from 17.1.2100 to 17.1.2100 is 0
#		And the maximum available quantity from 17.1.2100 to 18.1.2100 is 0
#		And the maximum available quantity from 18.1.2100 to 20.1.2100 is 1
#
## TODO 0402
##Scenario: Availability for level required items with pending orders
##	Given 1 model named Keyboard exists
##		And 2 items of that model exist
##		And 1 item requires level 1 
##		And 1 item requires level 2
##		And no pending order exists for Keyboard
##	Given 2 users named Pius and Claudio exist
##		And user Pius has borrowing level 1
##		And user Claudio has borrowing level 2
##	When Pius places an order for 1 Keyboard from 08.02.2010 to 12.02.2010
##	Then the Pius's order is approvable
##	When Claudio places an order for 1 Keyboard from 08.02.2010 to 12.02.2010
##	Then the Claudio's order is approvable
##		And the Pius's order is approvable [* here is the error!!!]	
