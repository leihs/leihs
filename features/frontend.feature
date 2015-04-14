#Feature: Test things that the customer can do in the frontend#
#
#Background: prepare a user and a few groups
#       Given inventory pool 'AVZ'
#         And a customer "Pepe"
#         And his password is 'pass'
#         And a group 'CAST'
#         And a model 'Prinzessin Lillifee Schaukel-Einhorn' exists
#         And item 'KF1' of model 'Prinzessin Lillifee Schaukel-Einhorn' exists
#
# @old-ui
#Scenario: The user needs to see models that are available in his groups
#         When I log in as 'Pepe' with password 'pass'
#          And I follow "Models"
#         Then I should see "Prinzessin Lillifee Schaukel-Einhorn"
#        Given comment: since it is in the general group
#
#         When an item is assigned to group "CAST"
#         When I reload the page
#          And I follow "Models"
#         Then I should not see "Prinzessin Lillifee Schaukel-Einhorn"
#        Given comment: since it is now in the "Cast" group
#        Given comment: to which "Pepe" has no access
#
#         When the customer "Pepe" is added to group "CAST"
#          And I reload the page
#          And I follow "Models"
#         Then I should see "Prinzessin Lillifee Schaukel-Einhorn"
#        Given comment: since I am also in group "CAST" now
