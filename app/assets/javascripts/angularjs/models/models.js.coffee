root = global ? window

angular.module("models", ["ngResource", "ng-rails-csrf"])
  .factory "Model", ['$resource', ($resource) ->
    Model = $resource("/backend/inventory_pools/:inventory_pool_id/models/:id",
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

    Model
  ]

root.angular = angular
