@ignore
Feature: Ensure that Culerity is working as it should
# this doesn't really test any of our features - thus the feature is disabled

	Scenario: Go to the home page and make sure it gets displayed
		Given I am on the home page
		Then I should see "leihs 2.3"

	Scenario: Enter some nonsensical credentials and see the flash warning be displayed
		Given I am on the home page
		 When I fill in "login_user" with "asdf1357"
		  And I press "Login"
		 Then I should see "Benutzername/Passwort ungültig"

