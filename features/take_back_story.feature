## The Take Back feature is waaaaay under-specified. The overwhelming majority
## of szenarios still need to be specified here
##
#Feature: Take Back
#
#	As an Inventory Manager
#	When Items have been handed over
#	Then we can't do much about them any more - thus
#	When once an Item has been handed over and even
#	When it is invalid
#	Then we do not want to trip over that fact
#	 And be able to take back the broken/invalid ItemLine anyway
#
#@old-ui
#Scenario: Because of a bug in leihs, we've handed over an Item twice, now we want to at least be able to take it back
#
#	Given a lending_manager for inventory pool 'ABC' logs in as 'inv_man_0'
#	Given a model 'NEC 245' exists
#	  And item 'AV_NEC245_1' of model 'NEC 245' exists only
#	Given there is only a signed contract by 'Joe' for item 'AV_NEC245_1'
#	  # the following step introduces an invalid entry!
#	  # AV_NEC245_1 is lent out twice!
#	  And a signed contract by 'Toshi' for item 'AV_NEC245_1'
#	When lending_manager clicks on 'take_back'
#	 And he chooses to take back Joe's entry
#	 And he selects all lines and takes the items back
#        Then Joe's contract should be closed
#	When lending_manager clicks on 'take_back'
#	 And he chooses to take back Toshi's entry
#	 And he selects all lines and takes the items back
#        Then Toshi's contract should be closed
