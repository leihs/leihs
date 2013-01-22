
UsersIndexCtrl = ($scope, User, $routeParams) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  # TODO reimplement with angular tabs
  $scope.setRole = (r)->
    $scope.role = r
    $(".inlinetabs .tab.active").removeClass "active"
    t = if r == "" then $(".inlinetabs .tab:first") else $(".inlinetabs .tab[value='"+r+"']")
    t.addClass("active")
    $scope.fetch()

  $scope.$watch 'suspended', (newValue, oldValue)->
    $scope.fetch()

  $scope.$watch 'search', (newValue, oldValue)->
    $scope.fetch()

  $scope.fetch = (nextPage)->
    return if $scope.isLoading
    return if nextPage and $scope.pagination.current_page >= $scope.pagination.total_pages
    $scope.isLoading = true
    params =
      inventory_pool_id: $scope.current_inventory_pool_id
      search: $scope.search
      role: $scope.role
      suspended: $scope.suspended
      page: nextPage
    # TODO this should be done directly by angular
    for k of params
      delete params[k] if angular.isUndefined(params[k])
    User.query(
      params
      , (response) ->
        new_users = (new User(entry) for entry in response.entries)
        $scope.users = if nextPage then $scope.users.concat new_users else new_users
        $scope.pagination = response.pagination
        $scope.isLoading = false
    )

UsersIndexCtrl.$inject = ['$scope', 'User', '$routeParams'];

UsersEditCtrl = ($scope, $location, $routeParams, User) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id
  $scope.possible_roles = [ {"name": "customer", "text": _jed("Customer")},
                            {"name": "lending_manager", "text": _jed("Lending manager")},
                            {"name": "inventory_manager", "text": _jed("Inventory manager")}]

  self = this
  User.get
    inventory_pool_id: $scope.current_inventory_pool_id
    id: $routeParams.id
  , (response) ->
    response.access_right.suspended_until = new Date(Date.parse(response.access_right.suspended_until)) if response.access_right.suspended_until?
    $scope.user = new User(response)

  $scope.save = ->
    User.update
      inventory_pool_id: $scope.current_inventory_pool_id
      id: $scope.user.id
      user:
        badge_id: $scope.user.badge_id
      access_right:
        role_name: $scope.user.access_right.role_name
        suspended_until: if $scope.user.access_right.suspended_until? then moment($scope.user.access_right.suspended_until).format("YYYY-MM-DD") else undefined
        suspended_reason: $scope.user.access_right.suspended_reason
    , (response) ->
      #$location.path "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/users/#{$scope.user.id}"
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/users/#{$scope.user.id}"

UsersEditCtrl.$inject = ['$scope', '$location', '$routeParams', 'User'];

# exports
root = global ? window
root.UsersIndexCtrl  = UsersIndexCtrl
root.UsersEditCtrl   = UsersEditCtrl