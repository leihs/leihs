Feature: Implement new Group feature#

        Background: Provide a minimal lending environment
                Given the settings are existing
                  And inventory pool 'AVZ'
                  And a lending_manager 'lending_manager' for inventory pool 'AVZ'
                  And I am logged in as 'lending_manager' with password 'foobar'

        Scenario: Have multiple groups, lend and return an item
                Given a customer "Mongo Bill"

                When I register a new model 'Olympus PEN E-P2'
                Then that model should not be available to anybody

                When I add 2 items of that model
                Then 2 items of that model should be available to everybody

                When I add 1 item of that model
                Then 3 items of that model should be available to everybody

                When I add a group called "CAST"

                Then 3 items of that model should be available to everybody
                 And that model should not be available in any group

                When I assign one item to group "CAST"
                Then 2 items of that model should be available to everybody
                 And one item of that model should be available in group 'CAST'

                Given a customer "Tomáš" that belongs to group "CAST"
                When I lend one item of that model to "Tomáš"
                Then 2 items of that model should be available to everybody

                When I add a group called "Video"
                 And I assign 2 items to group "Video"
                Then 0 items of that model should be available to "Tomáš"


        Scenario: Lend from specific groups and return to the general pool
                Given a model 'Olympus PEN E-P2' exists
                  And a customer "Mongo Bill"
                  And a group 'CAST'
                  And a customer "Tomáš" that belongs to group "CAST"

                When I add 1 item of that model
                 And I assign one item to group "CAST"
                Then 0 items of that model should be available to "Mongo Bill"

                When I add 1 item of that model
                 And I lend one item of that model to "Mongo Bill"
                 And I lend one item of that model to "Tomáš"
                Then 0 items of that model should be available to "Mongo Bill"

                When "Tomáš" returns the item
                Then one item of that model should be available to "Mongo Bill"
