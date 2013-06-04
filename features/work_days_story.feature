
Feature: Handling of workdays

       As an Inventory Manager
       I want to be able to define which days I work
       in order to not having to worry about somebody wanting to pick up or bring back something on a day I plan to stay home.

Scenario: Default Workdays

       When I try to order an item for 5.10.2030
       Then the order should not be approvable because it's a saturday
       
       When I try to order an item for 6.10.2030
       Then the order should not be approvable because it's a sunday
       
       When I try to order an item for 7.10.2030
       Then the order should be approvable
       
       When I try to order an item for 8.10.2030
       Then the order should be approvable
       
       When I try to order an item for 9.10.2030
       Then the order should be approvable
       
       When I try to order an item for 10.10.2030
       Then the order should be approvable
       
       When I try to order an item for 11.10.2030
       Then the order should be approvable
       
Scenario: Only works Mondays and Wednesdays

       Given inventory_pool is open on Monday, Wednesday

       When I try to order an item for 5.10.2030
       Then the order should not be approvable because it's a saturday

       When I try to order an item for 6.10.2030
       Then the order should not be approvable because it's a sunday

       When I try to order an item for 7.10.2030
       Then the order should be approvable (monday is open)

       When I try to order an item for 8.10.2030
       Then the order should not be approvable because it's a Tuesday

       When I try to order an item for 9.10.2030
       Then the order should be approvable (Wednesday is open)

       When I try to order an item for 10.10.2030
       Then the order should not be approvable because it's a Thursday

       When I try to order an item for 11.10.2030
       Then the order should not be approvable because it's a Friday

Scenario: With Holidays

       Given holidays are from 1.7.2030 - 29.7.2030 because of Summer Holiday
               And 1.1.2030 is free because of New Year
       
       When I try to order an item for 1.1.2030
       Then the order should not be approvable (because of New Year)
       
       When I try to order an item for 4.1.2030
       Then the order should be approvable
       
       When I try to order an item for 1.7.2030
       Then the order should not be approvable (because of Summer Holiday)
       
       When I try to order an item for 29.7.2030
       Then the order should not be approvable (because of Summer Holiday)
       
       When I try to order an item for 20.7.2030
       Then the order should not be approvable (because of Summer Holiday)
       
       When I try to order an item for 30.7.2030
       Then the order should be approvable
       
       When I try to order an item for 28.5.2030
       Then the order should be approvable


@old-ui
Scenario: Hand Over on a Sunday

       Given today is Sunday 3.10.2030
       When an inventory manager clicks 'hand over'
       And he tries to hand over an item to a customer
       Then that should be possible
       When trying to set the end date to the same date
       Then that should be possible because the inventory manager wants to be able to decide when he takes back things
       Given today is today again for test sanity's sake
       
@old-ui
Scenario: Hand Over during holiday

       Given 1.1.2030 is free because of New Year
               And today is Sunday 1.1.2030
       When an inventory manager clicks 'hand over'
               And he tries to hand over an item to a customer
       Then that should be possible
       When trying to set the end date to the same date
       Then that should be possible because the inventory manager wants to be able to decide when he takes back things
       Given today is today again for test sanity's sake

@old-ui
Scenario: Changing Workdays

       When an inventory manager clicks 'Opening Times'
       Then he sees that his inventory pool is currently open on monday, tuesday, wednesday, thursday, friday
       When he deselects the following days: tuesday, thursday, friday
               And he clicks 'Opening Times'
       Then he sees that his inventory pool is currently open on monday, wednesday
       When he selects the following day: friday
               And he clicks 'Opening Times'
       Then he sees that his inventory pool is currently open on monday, wednesday, friday
       
