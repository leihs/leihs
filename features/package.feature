#@old-ui
#Feature: Handling of Packages
#
#       As an Inventory Manager or a Customer
#       I want to be able to deal with Item Packages
#       # This feature could be possibly divided up
#       # into the respective process-oriented features
#       # instead in the future - or not
#
#Background: An inventory, a manager, a package with two items and a non-packaged item
#
#       Given 2 inventory pools
#       Given a inventory_manager for inventory pool '1' logs in as 'inv_man_0'
#         And we are using inventory pool '1' for now
#       Given a package 'Trololo Complete Edition' exists
#         And item 'TROLL' of model 'Trololo Complete Edition' exists
#             # 'Russian Singer Eduard Khil Remix'
#       Given item 'EKR' of model 'Khil Remix' exists
#         And item 'EKR' is part of package item TROLL
#             # 'I am very glad, because I'm finally returning back home (Trololo)'
#       Given item 'EKO' of model 'Khil Original' exists
#         And item 'EKO' is part of package item TROLL
#       Given 1 item of model 'Jimi Hendrix for the Connaisseur' exists
#       Given we are using inventory pool '2' for now
#         And item 'EKR_PLUS' of model 'Khil Remix' exists
#
#@old-ui
#Scenario: Don't show Model if it belongs to Package in Greybox and don't be influenced by other inventory pools
#
#       Given we are using inventory pool '1' for now
#       Given there is an order by 'Joe'
#         And it asks for 1 item of model 'Jimi Hendrix for the Connaisseur'
#         And the order was submitted
#       When the lending_manager clicks on 'acknowledge'
#        And he chooses Joe's order
#       Then Joe's order is shown
#       When lending_manager clicks to add an additional model
#       Then lending_manager sees 1 line 'Trololo Complete Edition'
#        And he sees 0 lines 'Khil Remix'
#        And even though 'Khil Remix' is not part of a package in inventory pool 2!
#        And he sees 0 lines 'Khil Original'
#
#@old-ui
#Scenario: If a Model is completely packaged in one Inventory Pool it can have an independent Item in another Inventory
#
#       Given we are using inventory pool '2' for now
#         And 1 item of model 'Tokio Nightlife' exists
#       Given there is an order by 'Toshi'
#         And it asks for 1 item of model 'Tokio Nightlife'
#         And the order was submitted
#       Given a lending_manager for inventory pool '2' logs in as 'inv_man_0'
#       When the lending_manager clicks on 'acknowledge'
#        And he chooses Toshi's order
#       Then Toshi's order is shown
#       When lending_manager clicks to add an additional model
#       Then lending_manager sees 0 line 'Trololo Complete Edition'
#        And he sees 1 lines 'Khil Remix'
#        And he sees 0 lines 'Khil Original'
#
