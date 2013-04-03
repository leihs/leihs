CategoriesIndexCtrl = ($scope, Category, $routeParams) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id
  $scope.fetch = (category_id)->
    $scope.isLoading = true
    Category.query(
      inventory_pool_id: $scope.current_inventory_pool_id
      category_id: category_id
      , (response) ->
        $scope.categories = (new Category(entry) for entry in response)
        $scope.isLoading = false
    )
  $scope.fetch(0)
  $scope.delete_category = -> 
    idToDelete = this.category.id
    deleteCatgoryRecursively = (categories)->
      for category in categories
        do (category)->
          if category.children.length?
            deleteCatgoryRecursively category.children
          if category.id == idToDelete
            catgories = categories.splice categories.indexOf(category), 1
    deleteCatgoryRecursively $scope.categories
    new Category(this.category).$delete
      id: idToDelete
      inventory_pool_id: $scope.current_inventory_pool_id
CategoriesIndexCtrl.$inject = ['$scope', 'Category', '$routeParams'];

CategoriesCreateCtrl = ($scope, Category, $routeParams, $location) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id
  $scope.category = new Category
  $scope.submit = ->
    Category.save
      inventory_pool_id: $scope.current_inventory_pool_id
      category:
        name: $scope.category.name
        model_group_links: _.uniq((_.map $(".model_group_link"), (link)-> {parent_id: $(link).data("parent_id"), label: $(link).find("input[type='text']").val()}), false, (i)->i.parent_id)
    , (response) ->
      #this is correct, but only refreshes the ng-view dom element# $location.path "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/categories"
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/categories"
    , (response) ->
      Notification.add_headline
        title: _jed('Error')
        text: response.data
        type: 'error'
CategoriesCreateCtrl.$inject = ['$scope', 'Category', '$routeParams', '$location'];

CategoriesEditCtrl = ($scope, Category, $routeParams, $location) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id
  $scope.category = Category.get
    inventory_pool_id: $scope.current_inventory_pool_id
    id: $routeParams.id
  $scope.submit = ->
    Category.update
      inventory_pool_id: $scope.current_inventory_pool_id
      id: $scope.category.id
      category:
        name: $scope.category.name
        model_group_links: _.uniq((_.map $(".model_group_link"), (link)-> {parent_id: $(link).data("parent_id"), label: $(link).find("input[type='text']").val()}), false, (i)->i.parent_id)
    , (response) ->
      #this is correct, but only refreshes the ng-view dom element#  $location.path "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/categories"
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/categories"
    , (response) ->
      Notification.add_headline
        title: _jed('Error')
        text: response.data
        type: 'error'
CategoriesEditCtrl.$inject = ['$scope', 'Category', '$routeParams', '$location'];

# exports
root = global ? window
root.CategoriesIndexCtrl  = CategoriesIndexCtrl
root.CategoriesCreateCtrl  = CategoriesCreateCtrl
root.CategoriesEditCtrl  = CategoriesEditCtrl
