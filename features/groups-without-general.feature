Feature: Implement new Group feature

	Background: Provide a minimal lending environment
	        Given inventory pool 'AVZ'

	Scenario: Have multiple groups, lend and return an item
		When I register a new Model 'Olympus PEN E-P2'
		Then that Model should not be available to anybody
		Then no items of that Model should be available in any group

		When I add 3 items of that Model
		Then 3 items of that Model should be available to everybody

		When I add a new Group "CAST"

		Then 3 items of that Model should be available to everybody
		 And that Model should not be available in any Group

		When I assign one item to Group "CAST"
		Then 2 items of that Model should be available to everybody
		 And one item of that Model should be available in Group 'CAST'

		Given a user "Tomáš" that belongs to Group "CAST"
		When I lend one item of Model "Olympus PEN E-P2" to "Tomáš"
		Then 2 items of that Model should be available to everybody
		 And no items of that Model should be available in Group 'CAST'
		 And one item of that Model should be borrowed in Group 'CAST'

		When "Tomáš" returns the item
		Then 2 items of that Model should be available to everybody
		 And one item of that Model should be available in Group 'CAST'

	# this Scenario expands on "Have multiple groups, lend and return an item"
	Scenario: Take from specific Group first and return to the same Group
		Given a model 'Olympus PEN E-P2' exists
		  And a Group "CAST"
		  And a user "Tomáš" that belongs to Group "CAST"
		  And a user "Franco" that belongs to Group "CAST"
		  And 2 items of that Model in Group "CAST"
		  And 2 items of that Model available to everybody

		When I lend 2 items of that Model to "Tomáš"
		Then 2 items of that Model should be borrowed in Group 'CAST'

		When I lend 2 items of that Model to "Franco"
		Then 2 items of that Model should be borrowed
		 But they should not be borrowed from any group

		When "Tomáš" returns 2 items
		Then 2 items of that Model should be available in Group 'CAST'
