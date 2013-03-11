ModelsCreateCtrl = ($scope, $location, $routeParams, Model) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  $scope.model = new Model
    accessories: []
    attachments: []
    images: []
  $scope.model.is_editable = true #tmp# TODO remove this when using permissions

  # TODO dry
  $scope.submit = ->
    $scope.isLoading = true
    $scope.process_images()

  # TODO dry
  $scope.process_images = ->
    new_images = _.groupBy($scope.model.images, (a)-> return not a.id?)
    $scope.model.images = new_images.false || []
    if (new_images.true || []).length
      i = 0
      for file in new_images.true
        reader = new FileReader()
        do (file)->
          reader.onload = (e) ->
            data_with_prefix = e.target.result
            $scope.model.images.push
              content_type: file.type
              filename: file.name
              size: file.size
              base64_string: data_with_prefix.match(/^data:.+\/(.+);base64,(.*)$/)[2]
            if new_images.true.length == ++i
              $scope.process_attachments()
        reader.readAsDataURL(file)
    else
      $scope.process_attachments()

  # TODO dry
  $scope.process_attachments = ->
    new_attachments = _.groupBy($scope.model.attachments, (a)-> return not a.id?)
    $scope.model.attachments = new_attachments.false || []
    if (new_attachments.true || []).length
      i = 0
      for file in new_attachments.true
        reader = new FileReader()
        do (file)->
          reader.onload = (e) ->
            data_with_prefix = e.target.result
            $scope.model.attachments.push
              content_type: file.type
              filename: file.name
              size: file.size
              base64_string: data_with_prefix.match(/^data:.+\/(.+);base64,(.*)$/)[2]
            if new_attachments.true.length == ++i
              $scope.real_submit()
        reader.readAsDataURL(file)
    else
      $scope.real_submit()

  $scope.real_submit = ->
    Model.save
      inventory_pool_id: $scope.current_inventory_pool_id
      model:
        name: $scope.model.name
        manufacturer: $scope.model.manufacturer
        description: $scope.model.description
        technical_detail: $scope.model.technical_detail
        internal_description: $scope.model.internal_description
        hand_over_note: $scope.model.hand_over_note
        images_attributes: $.extend({}, $scope.model.images)
        attachments_attributes: $.extend({}, $scope.model.attachments)
        accessories_attributes: $.extend({}, $scope.model.accessories)
        category_ids: $.unique($(".simple_tree input[type='checkbox']:checked").map(()-> return this.value ).toArray())
    , (response) ->
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models"
    , (response) ->
      $scope.isLoading = false
      Notification.add_headline
        title: _jed('Error')
        text: response.data
        type: 'error'

  # TODO dry
  $scope.setFile = (element, file_type) ->
    $scope.$apply ($scope) ->
      for file in element.files
        file.filename = file.name
        switch file_type
          when 1 then $scope.model.images.push file
          when 2 then $scope.model.attachments.push file

  # TODO dry
  $scope.addAccessory = (element) ->
    $scope.$apply ($scope) ->
      $scope.model.accessories.push {name: element.value, active: true}
      element.value = ""

  # TODO dry
  $scope.removeImage = (element)->
    $scope.model.images = _.reject $scope.model.images, (image)-> image is element.file

  # TODO dry
  $scope.removeAttachment = (element)->
    $scope.model.attachments = _.reject $scope.model.attachments, (attachment)-> attachment is element.file

  # TODO dry
  $scope.removeAccessory = (element)->
    $scope.model.accessories = _.reject $scope.model.accessories, (accessory)-> accessory is element.accessory


ModelsEditCtrl = ($scope, $location, $routeParams, Model) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id

  Model.get
    inventory_pool_id: $scope.current_inventory_pool_id
    id: $routeParams.id
  , (response) ->
    $scope.model = new Model(response)

  # TODO dry
  $scope.submit = ->
    $scope.isLoading = true
    $scope.process_images()

  # TODO dry
  $scope.process_images = ->
    new_images = _.groupBy($scope.model.images, (a)-> return not a.id?)
    $scope.model.images = new_images.false || []
    if (new_images.true || []).length
      i = 0
      for file in new_images.true
        reader = new FileReader()
        do (file)->
          reader.onload = (e) ->
            data_with_prefix = e.target.result
            $scope.model.images.push
              content_type: file.type
              filename: file.name
              size: file.size
              base64_string: data_with_prefix.match(/^data:.+\/(.+);base64,(.*)$/)[2]
            if new_images.true.length == ++i
              $scope.process_attachments()
        reader.readAsDataURL(file)
    else
      $scope.process_attachments()

  # TODO dry
  $scope.process_attachments = ->
    new_attachments = _.groupBy($scope.model.attachments, (a)-> return not a.id?)
    $scope.model.attachments = new_attachments.false || []
    if (new_attachments.true || []).length
      i = 0
      for file in new_attachments.true
        reader = new FileReader()
        do (file)->
          reader.onload = (e) ->
            data_with_prefix = e.target.result
            $scope.model.attachments.push
              content_type: file.type
              filename: file.name
              size: file.size
              base64_string: data_with_prefix.match(/^data:.+\/(.+);base64,(.*)$/)[2]
            if new_attachments.true.length == ++i
              $scope.real_submit()
        reader.readAsDataURL(file)
    else
      $scope.real_submit()

  $scope.real_submit = ->
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
        images_attributes: $.extend({}, $scope.model.images)
        attachments_attributes: $.extend({}, $scope.model.attachments)
        accessories_attributes: $.extend({}, $scope.model.accessories)
        category_ids: $.unique($(".simple_tree input[type='checkbox']:checked").map(()-> return this.value ).toArray())
    , (response) ->
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models"
    , (response) ->
      $scope.isLoading = false
      Notification.add_headline
        title: _jed('Error')
        text: response.data
        type: 'error'

  # TODO dry
  $scope.setFile = (element, file_type) ->
    $scope.$apply ($scope) ->
      for file in element.files
        file.filename = file.name
        switch file_type
          when 1 then $scope.model.images.push file
          when 2 then $scope.model.attachments.push file



  # TODO dry
  $scope.addAccessory = (element) ->
    $scope.$apply ($scope) ->
      $scope.model.accessories.push {name: element.value, active: true}
      element.value = ""

  # TODO dry
  $scope.removeImage = (element)->
    $scope.model.images = _.reject $scope.model.images, (image)-> image is element.file

  # TODO dry
  $scope.removeAttachment = (element)->
    $scope.model.attachments = _.reject $scope.model.attachments, (attachment)-> attachment is element.file

  # TODO dry
  $scope.removeAccessory = (element)->
    $scope.model.accessories = _.reject $scope.model.accessories, (accessory)-> accessory is element.accessory

ModelsCreateCtrl.$inject = ['$scope', '$location', '$routeParams', 'Model'];
ModelsEditCtrl.$inject = ['$scope', '$location', '$routeParams', 'Model'];

# exports
root = global ? window
root.ModelsCreateCtrl   = ModelsCreateCtrl
root.ModelsEditCtrl   = ModelsEditCtrl
