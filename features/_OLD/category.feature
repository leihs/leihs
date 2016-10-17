#Feature: Creating and editing the category tree in the backend
#  As admin or inventory manager, I want to add new categories
#  to the system and manage the category tree (parents, children).
#
#  #Background: We have a manager as well as stuff in categories
#    #Given a minimal leihs setup
#      #And inventory pool 'MyPool'
#      #And a inventory_manager 'inv_man_0' for inventory pool 'MyPool'
#      #And his password is 'pass'
#      #And a category 'Tierkörperteile' exists
#      #And a category 'Hasenartige' exists
#      #And a category 'Allgemein' exists
#      #And the category 'Hasenartige' is child of 'Tierkörperteile' with label 'Hasenartige'
#      #And the category 'Allgemein' is child of 'Tierkörperteile' with label 'Allgemein'
#      #And a model 'Hasenpfote' exists
#      #And a model 'Hasenohr' exists
#      #And the model 'Hasenpfote' belongs to the category 'Hasenartige'
#      #And the model 'Hasenohr' belongs to the category 'Hasenartige'
#      #And I log in as 'inv_man_0' with password 'pass'
#      #And I press "Backend"
#      #And I follow "MyPool"
#
#   @logoutafter @old-ui
#  Scenario: Browsing the category list to verify that there's something in it
#    When I follow the sloppy link "All Models"
#    Then I should see "Hasenpfote"
#     And I should see "Hasenohr"
#
#   @logoutafter @old-ui
#  Scenario: Browsing a specific category
#     Then the model "Hasenohr" should be in category "Hasenartige"
#
#   @logoutafter @old-ui
#  Scenario: Assigning a model to a category when there are few categories
#    When I follow the sloppy link "All Models"
#     And I pick the model "Hasenohr" from the list
#     And I follow "Categories (1)"
#     And I check the category "Allgemein"
#    Then I should see "This model is now in 2 categories" within "#flash"
#     And the model "Hasenohr" should be in category "Allgemein"
#     And the model "Hasenohr" should be in category "Hasenartige"
#
#   @logoutafter @old-ui
#  Scenario: Assigning a model to a category when there are more categories
#   Given a category 'Fuchshafte' exists
#     And the category 'Fuchshafte' is child of 'Tierkörperteile' with label 'Fuchshafte'
#     And a model 'Fuchsschwanz' exists
#     And the model 'Fuchsschwanz' belongs to the category 'Fuchshafte'
#     When I follow "MyPool"
#     And I follow the sloppy link "All Models"
#     And I pick the model "Fuchsschwanz" from the list
#     And I follow "Categories (1)"
#     And I check the category "Allgemein"
#    Then I should see "This model is now in 2 categories" within "#flash"
#     And the model "Fuchsschwanz" should be in category "Allgemein"
#     And the model "Fuchsschwanz" should be in category "Fuchshafte"
#
#   @logoutafter @old-ui
#  Scenario: Removing a model from a category
#   Given a category 'Fuchshafte' exists
#     And a category 'Benzinkanister' exists
#     And the category 'Fuchshafte' is child of 'Tierkörperteile' with label 'Fuchshafte'
#     And a model 'Fuchsschwanz' exists
#     And the model 'Fuchsschwanz' belongs to the category 'Fuchshafte'
#     And the model 'Fuchsschwanz' belongs to the category 'Benzinkanister'
#     When I follow "MyPool"
#     And I follow the sloppy link "All Models"
#     And I pick the model "Fuchsschwanz" from the list
#     And I follow "Categories (2)"
#     And I uncheck the category "Benzinkanister"
#    Then I should see "This model is now in 1 categories" within "#flash"
#     And the model "Fuchsschwanz" should be in category "Fuchshafte"
#     And the model "Fuchsschwanz" should not be in category "Benzinkanister"
