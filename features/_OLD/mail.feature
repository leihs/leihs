#Feature: Send Emails to Users
#
#       As an Inventory Manager
#       I want to be able to send an email to users
#       To ask them f.ex. whether they could bring back stuff earlier
#
#Background:
#       Given a minimal leihs setup
#       Given comment: the admin
#       Given comment: And the mail queue is empty
#       Given comment: And we setup Culerity Logging as we like
#
#
# @old-ui
#Scenario: Admin: create user and directly mail him
#
#       When I log in as the admin
#       When I press "Backend"
#        And I create a new user 'Joe' at 'joe@example.com'
#       When I follow "Write Email"
#       Then I should be on the new backend mail page
#       When I fill in "subject" with "Welcome to leihs"
#        And I fill in "body" with "Now you can borrow stuff"
#        And I press "Send"
#       Then joe@example.com receives an email
#       Then I follow "Logout"
#
# @old-ui
#Scenario: Admin: create user in an inventory pool and mail him from there
#
#       Given inventory pool 'Central Park'
#         And the admin
#         And he is a inventory_manager
#       When I log in as the admin
#       When I press "Backend"
#       When I follow "Central Park"
#        And I create a new user 'Joe' at 'joe@example.com'
#       When I follow "Write Email"
#        And I fill in "subject" with "Welcome to leihs"
#        And I fill in "body" with "Now you can borrow stuff"
#        And I press "Send"
#       Then joe@example.com receives an email
#       Then I follow "Logout"
#
# @old-ui
#Scenario: When mailing from a greybox then we should stay in it
#
#       Given inventory pool 'Central Park'
#         And the admin
#         And he is a inventory_manager
#      When I log in as the admin
#      When I press "Backend"
#      When I follow "Central Park"
#       And I create a new user 'Joe' at 'joe@example.com'
#      When I follow "Users"
#       And I follow the sloppy link "New Contract"
#      When I follow "Joe"
#      Then I should be in a greybox
#      When I follow "Write Email"
#      Then I should still be in a greybox
#      When I fill in "subject" with "Welcome to leihs"
#       And I fill in "body" with "Now you can borrow stuff"
#       And I press "Send"
#      Then joe@example.com receives an email
#       And I should be back to the same greybox as after 'When I follow "Joe"'
#      Then I follow "Logout"


