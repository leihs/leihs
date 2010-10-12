Feature: Implement new Group feature

	Background: Provide a minimal lending environment
	        Given inventory pool 'AVZ'
		Given a customer "Foo Bear"

	Scenario: Have multiple groups, lend and return an item
		When I register a new model 'Olympus PEN E-P2'
		Then that model should not be available to anybody

		When I add 2 items of that model
		Then 2 items of that model should be available to everybody

		When I add 1 item of that model
		Then 3 items of that model should be available to everybody

		When I add a new group "CAST"

		Then 3 items of that model should be available to everybody
		 And that model should not be available in any group

		When I assign one item to group "CAST"
		Then 2 items of that model should be available to everybody
		 And one item of that model should be available in group 'CAST'

		Given a customer "Tomáš" that belongs to group "CAST"
		When I lend one item of model "Olympus PEN E-P2" to "Tomáš"
		Then 2 items of that model should be available to everybody
		 And no items of that model should be available in group 'CAST'
		 And one item of that model should be borrowed in group 'CAST'

		When "Tomáš" returns the item
		Then 2 items of that model should be available to everybody
		 And one item of that model should be available in group 'CAST'

	# this Scenario expands on "Have multiple groups, lend and return an item"
	Scenario: Take from specific group first and return to the same group
		Given a model 'Olympus PEN E-P2' exists
		  And a group "CAST"
		  And a customer "Tomáš" that belongs to group "CAST"
		  And a customer "Franco" that belongs to group "CAST"
		  And 2 items of that model in group "CAST"
		  And 2 items of that model available to everybody

		When I lend 2 items of that model to "Tomáš"
		Then 2 items of that model should be borrowed in group 'CAST'

		When I lend 2 items of that model to "Franco"
		Then 2 items of that model should be borrowed
		 But they should not be borrowed from any group

		When "Tomáš" returns 2 items
		Then 2 items of that model should be available in group 'CAST'
