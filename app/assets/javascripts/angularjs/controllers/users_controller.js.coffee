
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
    User.get(
      params
      , (response) ->
        if nextPage
          $scope.users = $scope.users.concat response.entries
        else
          $scope.users = response.entries
        $scope.pagination = response.pagination
        $scope.isLoading = false
    )

UsersIndexCtrl.$inject = ['$scope', 'User', '$routeParams'];

UsersEditCtrl = ($scope, $location, $routeParams, User) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  self = this
  User.get
    inventory_pool_id: $scope.current_inventory_pool_id
    id: $routeParams.id
  , (response) ->
    $scope.user = new User(response)
    $scope.user.access_right.suspended_until = moment($scope.user.access_right.suspended_until).format(i18n.date.L) if $scope.user.access_right.suspended_until

  $scope.save = ->
    User.update
      inventory_pool_id: $scope.current_inventory_pool_id
      id: $scope.user.id
      user:
        badge_id: $scope.user.badge_id
      access_right:
        suspended_until: moment($scope.user.access_right.suspended_until).format("YYYY-MM-DD")
        suspended_reason: $scope.user.access_right.suspended_reason
    , (response) ->
      #$location.path "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/users/#{$scope.user.id}"
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/users/#{$scope.user.id}"

UsersEditCtrl.$inject = ['$scope', '$location', '$routeParams', 'User'];

# exports
root = global ? window
root.UsersIndexCtrl  = UsersIndexCtrl
root.UsersEditCtrl   = UsersEditCtrl