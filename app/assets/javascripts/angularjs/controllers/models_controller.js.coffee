ModelsCreateCtrl = ($scope, $location, $routeParams, Model) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  $scope.model = new Model()
  $scope.model.is_editable = true #tmp# TODO remove this when using permissions

  $scope.save = ->
    Model.save
      inventory_pool_id: $scope.current_inventory_pool_id
      model:
        name: $scope.model.name
        manufacturer: $scope.model.manufacturer
        description: $scope.model.description
        technical_detail: $scope.model.technical_detail
        internal_description: $scope.model.internal_description
        hand_over_note: $scope.model.hand_over_note
    , (response) ->
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models"
    , (response) ->
      Notification.add_headline
        title: _jed('Error')
        text: response.data
        type: 'error'

  # TODO dry
  $scope.setFile = (element) ->
    $scope.$apply ($scope) ->
      $scope.model.attachments = element.files




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
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models"

  # TODO dry
  $scope.setFile = (element) ->
    $scope.$apply ($scope) ->
      $scope.model.attachments = element.files



ModelsCreateCtrl.$inject = ['$scope', '$location', '$routeParams', 'Model'];
ModelsEditCtrl.$inject = ['$scope', '$location', '$routeParams', 'Model'];

# exports
root = global ? window
root.ModelsCreateCtrl   = ModelsCreateCtrl
root.ModelsEditCtrl   = ModelsEditCtrl
