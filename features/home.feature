#Feature: Ensure that accessing through the frontend is working as it should
#
#       @old-ui
#       Scenario: Go to the home page and make sure it gets displayed
#               Given I am on the home page
#               Then I should see "leihs 2.9"
#       @old-ui
#       Scenario: Enter some nonsensical credentials and see the flash warning be displayed
#               Given I am on the home page
#                When I fill in "login_user" with "asdf1357"
#                 And I press "Login"
#                Then I should see "Invalid username/password"
