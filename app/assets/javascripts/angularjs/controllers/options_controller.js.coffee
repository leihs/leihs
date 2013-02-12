
OptionsEditCtrl = ($scope, $location, $routeParams, Option) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  if $routeParams.id # TODO separate in a CreateCtrl ??
    Option.get
      inventory_pool_id: $scope.current_inventory_pool_id
      id: $routeParams.id
    , (response) ->
      $scope.option = new Option(response)
      $scope.option.is_editable = true #tmp# TODO remove this when using permissions
  else
    $scope.option = new Option()
    $scope.option.is_editable = true #tmp# TODO remove this when using permissions

  $scope.save = ->
    if $routeParams.id # TODO separate in a CreateCtrl ??
      Option.update
        inventory_pool_id: $scope.current_inventory_pool_id
        id: $scope.option.id
        option:
          name: $scope.option.name
          price: $scope.option.price
          inventory_code: $scope.option.inventory_code
      , (response) ->
        window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models"
    else
      Option.save
        inventory_pool_id: $scope.current_inventory_pool_id
        option:
          name: $scope.option.name
          price: $scope.option.price
          inventory_code: $scope.option.inventory_code
      , (response) ->
        window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models"

  $scope.setFile = (element) ->
    $scope.$apply ($scope) ->
      $scope.option.attachments = element.files

OptionsEditCtrl.$inject = ['$scope', '$location', '$routeParams', 'Option'];

# exports
root = global ? window
root.OptionsEditCtrl   = OptionsEditCtrl