root = global ? window

angular.module("users", ["ngResource", "ng-rails-csrf"])
  .factory "User", ['$resource', ($resource) ->
    User = $resource("/backend/inventory_pools/:inventory_pool_id/users/:id",
      id: "@id",
      inventory_pool_id: "@inventory_pool_id"
    ,
      update:
        method: "PUT"
      destroy:
        method: "DELETE"
    )
    User::destroy = (cb) ->
      User.remove
        id: @id
      , cb

    User
  ]

root.angular = angular
