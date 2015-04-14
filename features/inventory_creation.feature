#Feature: Creating Inventory Pools
#
#       Describing Inventory Pool creation
#
#Background:
#       Given a minimal leihs setup
#
# @old-ui
#Scenario: When an inventory is created, it should be visible in the frontend at once
#
#       When I log in as the admin
#         And I press "Backend"
#         And I follow "InventoryPools"
#         And I follow "Create New"
#        # ugly
#        And I fill in "inventory_pool_name" with "Poolice"
#         And I press "Submit"
#         And I follow "All Models"
#         And I follow "Create New"
#        And I fill in "model_name" with "Moodel"
#         And I press "Submit"
#         And I follow the sloppy link "Items" within ".model_backend_tabnav"
#         And I follow "New Item"
#        # ugly
#         And I choose "item_is_borrowable_true"
#         And I select "Poolice" from "item_inventory_pool_id"
#         And I press "Create"
#         # Reindexing shouldn't be necessary
#         And I reindex
#         And I follow the sloppy link "Frontend"
#        When I wait for the spinner to disappear
#         And I follow the sloppy link "Models"
#        Then I should see "Moodel"

