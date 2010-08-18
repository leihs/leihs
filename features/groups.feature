@ignore
Feature: Implement new Group feature

	Scenario: Check that we have implemented Groups and Availability right
	        Given I have an InventoryPool AVZ
		When I register a new Model "Olympus PEN E-P2"
		Then 0 Items of that Model should be available in Group "General"
		 And that model should not be available in any other Group
		Then 0 Items of that Model should be borrowed to any group
		 And 0 Items of that Model should be unborrowable in any group

		When I add 3 Items of that Model
		Then 3 Items of that Model should be available in Group "General" only

		When I add a new Group "CAST" to InventoryPool AVZ
		Then 3 Items of that Model should be available in Group "General" only

		When I move one Item of that Model from Group "General" to Group "CAST"
		Then 2 Items of that Model should be available in Group "General"
		 And 1 Items of that Model should be available in Group "CAST"
		 And that model should not be available in any other Group

		Given I have a user "Tomáš"
		Then 3 Items of that Model should be available in Group "General" only



