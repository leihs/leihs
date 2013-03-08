root = global ? window

angular.module("categories", ["ngResource", "ng-rails-csrf"])
  .factory "Category", ['$resource', ($resource) ->
    Category = $resource("/backend/inventory_pools/:inventory_pool_id/categories/:id",
      id: "@id",
      inventory_pool_id: "@inventory_pool_id"
    ,
      update:
        method: "PUT"
      delete:
        method: "DELETE"
    )

    Category
  ]

root.angular = angular
