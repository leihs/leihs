root = global ? window

angular.module("users", ["ngResource", "ng-rails-csrf"])
  .factory "User", ['$resource', ($resource) ->
    User = $resource("/backend/inventory_pools/:inventory_pool_id/users/:id",
      id: "@id",
      inventory_pool_id: "@inventory_pool_id"
    ,
      query:
        method: "GET"
        isArray: false
      update:
        method: "PUT"
      destroy:
        method: "DELETE"
    )

    User::role_text = ()->
      if @access_right?
        switch @access_right.role_name
          when "admin" then _jed("Administrator")
          when "customer" then _jed("Customer")
          when "lending_manager" then _jed("Lending manager")
          when "inventory_manager" then _jed("Inventory manager")
          else _jed("No access")
      else
        _jed("No access")

    User
  ]

root.angular = angular
