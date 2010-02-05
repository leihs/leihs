Feature: Inventory

	Describing Inventory Pools, Items, Models and Categories
	
	
Scenario: Categories structure
	
	Given a category 'Cameras' exists
		And a category 'Video Equipment' exists
		And a category 'Film' exists
		And a category 'Video' exists
		And a category 'Filters' exists
		And the category 'Film' is child of 'Cameras' with label 'Film'
		And the category 'Video' is child of 'Cameras' with label 'Video'
		And the category 'Video' is child of 'Video Equipment' with label 'Video Cameras'
		And the category 'Filters' is child of 'Video' with label 'Filters'
	When the category 'Cameras' is selected	
	Then there are 2 direct children and 3 total children
		And the label of the direct children are 'Film,Video'
	When the category 'Video Equipment' is selected	
	Then there are 1 direct children and 2 total children
		And the label of the direct children are 'Video Cameras'
	When the category 'Film' is selected	
	Then there are 0 direct children and 0 total children
	When the category 'Video' is selected	
	Then there are 1 direct children and 1 total children
		And the label of the direct children are 'Filters'
	When the category 'Filters' is selected	
	Then there are 0 direct children and 0 total children 	 	

	
Scenario: Models organized in categories
	
	Given a category 'Cameras' exists
		And a category 'Video' exists
		And a model 'Sony 333' exists
		And the model 'Sony 333' belongs to the category 'Cameras'
		And a model 'Canon 444' exists
		And the model 'Canon 444' belongs to the category 'Cameras'
		And a model 'Beamer 123' exists
		And the model 'Beamer 123' belongs to the category 'Video'
	When the category 'Cameras' is selected	
	Then there are 2 models belonging to that category
	When the category 'Video' is selected	
	Then there are 1 models belonging to that category
		