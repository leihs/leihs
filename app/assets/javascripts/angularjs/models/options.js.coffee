root = global ? window

angular.module("options", ["ngResource", "ng-rails-csrf"])
  .factory "Option", ['$resource', ($resource) ->
    Option = $resource("/backend/inventory_pools/:inventory_pool_id/options/:id",
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

    Option
  ]

root.angular = angular
