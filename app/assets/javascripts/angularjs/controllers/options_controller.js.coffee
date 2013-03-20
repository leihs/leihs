OptionsCreateCtrl = ($scope, $location, $routeParams, Option) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  $scope.option = new Option()
  $scope.option.is_editable = true #tmp# TODO remove this when using permissions

  $scope.save = ->
    Option.save
      inventory_pool_id: $scope.current_inventory_pool_id
      option:
        name: $scope.option.name
        price: $scope.option.price
        inventory_code: $scope.option.inventory_code
    , (response) ->
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/inventory"



OptionsEditCtrl = ($scope, $location, $routeParams, Option) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  Option.get
    inventory_pool_id: $scope.current_inventory_pool_id
    id: $routeParams.id
  , (response) ->
    $scope.option = new Option(response)
    $scope.option.is_editable = true #tmp# TODO remove this when using permissions

  $scope.save = ->
    Option.update
      inventory_pool_id: $scope.current_inventory_pool_id
      id: $scope.option.id
      option:
        name: $scope.option.name
        price: $scope.option.price
        inventory_code: $scope.option.inventory_code
    , (response) ->
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/inventory"



OptionsCreateCtrl.$inject = ['$scope', '$location', '$routeParams', 'Option'];
OptionsEditCtrl.$inject = ['$scope', '$location', '$routeParams', 'Option'];

# exports
root = global ? window
root.OptionsCreateCtrl   = OptionsCreateCtrl
root.OptionsEditCtrl   = OptionsEditCtrl