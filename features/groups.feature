@ignore
Feature: Implement new Group feature
# These tests were implemented with a 'General' group in mind, which
# doesn't exist in Franco's design
#
# See groups-without-general.feature instead

	Background: Provide a minimal lending environment
	        Given inventory pool 'AVZ'

	Scenario: a user is automatically in group 'General'

		When I create a user 'Richard'
		Then he must be in Group 'General'

	       Given inventory pool 'Lectures in comix'
		When I give the user 'Richard' access to the inventory pool 'Lectures in comix'
		Then he must be in Group 'General' in inventory pool 'Lectures in comix'
		# TODO:
		# When I remove from user 'Richard' access to the inventory pool 'Lectures in comix'
		# Then he must be not be in Group 'General' in inventory pool 'Lectures in comix'

	Scenario: Have multiple groups, lend and return an item
		When I register a new Model 'Olympus PEN E-P2'
		Then no items of that Model should be available in Group 'General'
		 And that Model should not be available in any other Group
		Then no items of that Model should be borrowed in any group

		When I add 3 items of that Model
		Then 3 items of that Model should be available in Group 'General' only

		When I add a new Group "CAST"

		Then 3 items of that Model should be available in Group 'General' only
		 And that Model should not be available in any other Group

		When I move one item of that Model from Group "General" to Group "CAST"
		Then 2 items of that Model should be available in Group 'General'
		 And one item of that Model should be available in Group 'CAST'

		Given a user "Tomáš" that belongs to Group "CAST"
		When I lend one item of Model "Olympus PEN E-P2" to "Tomáš"
		Then 2 items of that Model should be available in Group 'General'
		 And no items of that Model should be borrowable in Group 'CAST'
		 And no items of that Model should be unborrowable in any group
		 And one item of that Model should be borrowed in Group 'CAST'

		When "Tomáš" returns the item
		Then 2 items of that Model should be available in Group 'General'
		 And one item of that Model should be borrowable in Group 'CAST'

	# this Scenario expands on "Have multiple groups, lend and return an item"
	Scenario: Take from specific Group first and return to the same Group
		Given a model 'Olympus PEN E-P2' exists
		  And a Group "CAST"
		  And a user "Tomáš" that belongs to Group "CAST"
		  And a user "Franco" that belongs to Group "CAST"
		  And 2 items of that Model in Group "CAST"
		  And 2 items of that Model in Group "General"

		When I lend 2 items of that Model to "Tomáš"
		Then 2 items of that Model should be borrowed in Group 'CAST'

		When I lend 2 items of that Model to "Franco"
		Then 2 items of that Model should be borrowed in Group 'General'

		When "Tomáš" returns 2 items
		Then 2 items of that Model should be available in Group 'CAST'
