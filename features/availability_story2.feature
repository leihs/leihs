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


Scenario: In Repair
  Given 7 items of model 'NEC 245' exist
    And a reservation exists for 3 'NEC 245' from 21.3.2030 to 31.3.2030
    And lending_manager marks 1 'NEC 245' as 'in-repair' on 18.3.2030
   When lending_manager checks availability for 'NEC 245'
   Then the maximum available quantity on 20.3.2030 is 6
    And the maximum available quantity on 21.3.2030 is 3

Scenario: Not Returned
  Given 1 items of model 'Lasersword Grendab' exist
    And a contract exists for 1 'Lasersword Grendab' from 1.1.2030 to 5.1.2030
   When lending_manager checks availability for 'Lasersword Grendab'
   Then if I check the maximum available quantity for 8.1.2030 it is 1 on 4.1.2030
   Then if I check the maximum available quantity for 8.1.2030 it is 1 on 6.1.2030
  Given the lending_manager signs the contract
   When lending_manager checks availability for 'Lasersword Grendab'
   Then if I check the maximum available quantity for 8.1.2030 it is 1 on 4.1.2030
   Then if I check the maximum available quantity for 8.1.2030 it is 0 on 6.1.2030
  
Scenario: Reservations from the past
  Given 3 items of model 'Lasersword Grendab' exist
    And the maintenance period for this model is 2 days
    And a reservation exists for 1 'Lasersword Grendab' from 1.1.1999 to 5.10.2030
   When lending_manager checks availability for 'Lasersword Grendab' on 6.1.2030
   Then the maximum available quantity on 8.1.2030 is 2
    And the maximum available quantity on 15.2.2222 is 3

Scenario: Availability for a period of time
  Given 3 items of model 'Lasersword Grendab' exist
    And a reservation exists for 1 'Lasersword Grendab' from 17.1.2030 to 27.2.2030
   When lending_manager checks availability for 'Lasersword Grendab'
   Then the maximum available quantity from 16.1.2030 to 28.2.2030 is 2
    And the maximum available quantity from 10.1.2030 to 16.1.2030 is 3
    And the maximum available quantity from 10.1.2030 to 17.1.2030 is 2
    And the maximum available quantity from 19.1.2030 to 22.1.2030 is 2
    And the maximum available quantity from 22.2.2030 to 1.3.2030 is 2
    And the maximum available quantity from 27.2.2030 to 1.3.2030 is 2
    And the maximum available quantity from 28.2.2030 to 5.4.2030 is 3

Scenario: Availability for a period - complicated
  Given 3 items of model 'Lasersword Grendab' exist
    And a reservation exists for 1 'Lasersword Grendab' from 17.1.2030 to 27.2.2030
    And a reservation exists for 1 'Lasersword Grendab' from 20.1.2030 to 5.2.2030
    And a reservation exists for 1 'Lasersword Grendab' from 1.2.2030 to 9.3.2030
   When lending_manager checks availability for 'Lasersword Grendab'
   Then the maximum available quantity from 10.1.2030 to 16.1.2030 is 3
    And the maximum available quantity from 17.1.2030 to 28.2.2030 is 0
    And the maximum available quantity from 17.1.2030 to 31.1.2030 is 1
    And the maximum available quantity from 1.2.2030 to 5.2.2030 is 0
    And the maximum available quantity from 6.2.2030 to 15.3.2030 is 1
    And the maximum available quantity from 28.2.2030 to 31.3.2030 is 2
    And the maximum available quantity from 6.1.2030 to 1.2.2030 is 0

Scenario: A reservation of a single day should be blocking
  Given reported by HKB on 1.June 2010 as #225
  Given 1 item of model 'RepRap' exist
    And a reservation exists for 1 'RepRap' from 17.1.2030 to 17.1.2030
   When lending_manager checks availability for 'RepRap'
   Then the maximum available quantity from 15.1.2030 to 20.1.2030 is 0
    And the maximum available quantity from 15.1.2030 to 16.1.2030 is 1
    And the maximum available quantity from 16.1.2030 to 17.1.2030 is 0
    And the maximum available quantity from 17.1.2030 to 17.1.2030 is 0
    And the maximum available quantity from 17.1.2030 to 18.1.2030 is 0
    And the maximum available quantity from 18.1.2030 to 20.1.2030 is 1

# Does not work due to completely new UI       
@old-ui
Scenario: Future, unassigned reservations should not influence the present
  Given 1 item of model 'RepRap' exist
    And a reservation exists for 1 'RepRap' from 17.1.2030 to 17.1.2030
    And a reservation exists for 1 'RepRap' from 20.1.2030 to 20.1.2030
  Given 'lending_manager' has password 'foobar'
   When I am logged in as 'lending_manager' with password 'foobar'
    And I check the availability changes for 'RepRap'
   Then no reservation should show an influence on today's borrowability
   Then one reservation should show an influence on the borrowability on 17.01.2030
   Then no reservation should show an influence on the borrowability on 18.01.2030

# Does not work due to completely new UI       
@old-ui
Scenario: Future, assigned reservations should influence the present
  Given 1 item of model 'RepRap' exist
          And a contract exists for 1 'RepRap' from 17.1.2030 to 17.1.2030
  Given 'lending_manager' has password 'foobar'
   When I am logged in as 'lending_manager' with password 'foobar'
    And I check the availability changes for 'RepRap'
   Then one reservation should show an influence on today's borrowability
    And no reservation should show an influence on the borrowability on 18.01.2030
