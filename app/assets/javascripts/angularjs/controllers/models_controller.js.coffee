
ModelsEditCtrl = ($scope, $location, $routeParams, Model) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  Model.get
    inventory_pool_id: $scope.current_inventory_pool_id
    id: $routeParams.id
  , (response) ->
    $scope.model = new Model(response)

  $scope.save = ->
    Model.update
      inventory_pool_id: $scope.current_inventory_pool_id
      id: $scope.model.id
      model:
        name: $scope.model.name
        manufacturer: $scope.model.manufacturer
        description: $scope.model.description
        technical_detail: $scope.model.technical_detail
        internal_description: $scope.model.internal_description
        hand_over_note: $scope.model.hand_over_note
    , (response) ->
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models/#{$scope.model.id}"

ModelsEditCtrl.$inject = ['$scope', '$location', '$routeParams', 'Model'];

# exports
root = global ? window
root.ModelsEditCtrl   = ModelsEditCtrl