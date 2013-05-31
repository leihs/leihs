ModelsCreateCtrl = ($scope, $location, $routeParams, Model) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id
  $scope.action = "create"

  $(".left").append($("#model-categories"))

  $scope.model = new Model
    accessories: []
    attachments: []
    images: []
    properties: []
    compatibles: []
    packages: []
    partitions: []

  $scope.model.is_package = true
  $scope.model.is_editable = true #tmp# TODO remove this when using permissions

  $scope.submit = -> submit($scope)
  $scope.process_images = -> process_images($scope)
  $scope.process_attachments = -> process_attachments($scope)
  $scope.real_submit = -> real_submit($scope, "save", Model)
  $scope.setFile = (element, file_type) -> setFile($scope, element, file_type)
  $scope.addAccessory = (element)-> addAccessory($scope, element)
  $scope.removeImage = (element)-> removeImage($scope, element)
  $scope.removeAttachment = (element)-> removeAttachment($scope, element)
  $scope.removeAccessory = (element)-> removeAccessory($scope, element)
  $scope.addProperty = -> addProperty($scope)
  $scope.removeProperty = (element)-> removeProperty($scope, element)
  $scope.openPackageDialog = (element)-> openPackageDialog($scope, element)
  $scope.deletePackage = (element)-> deletePackage($scope, element)
  $scope.addCompatible = (element) -> addCompatible($scope, element)  
  $scope.removeCompatible = (element)-> removeCompatible($scope, element)
  $scope.addPartition = (element) -> addPartition($scope, element)  
  $scope.removePartition = (element) -> removePartition($scope, element)  

ModelsEditCtrl = ($scope, $location, $routeParams, Model) ->
  $scope.current_inventory_pool_id = $routeParams.inventory_pool_id
  $scope.action = "edit"

  $(".left").append($("#model-categories"))

  Model.get
    inventory_pool_id: $scope.current_inventory_pool_id
    id: $routeParams.id
  , (response) ->
    $scope.model = new Model(response)
    $scope.model.packages = $scope.model.packages.reverse()

  $scope.submit = -> submit($scope)
  $scope.process_images = -> process_images($scope)
  $scope.process_attachments = -> process_attachments($scope)
  $scope.real_submit = -> real_submit($scope, "update", Model)
  $scope.setFile = (element, file_type) -> setFile($scope, element, file_type)
  $scope.addAccessory = (element)-> addAccessory($scope, element)
  $scope.removeImage = (element)-> removeImage($scope, element)
  $scope.removeAttachment = (element)-> removeAttachment($scope, element)
  $scope.removeAccessory = (element)-> removeAccessory($scope, element)
  $scope.addProperty = -> addProperty($scope)
  $scope.removeProperty = (element)-> removeProperty($scope, element)
  $scope.openPackageDialog = (element)-> openPackageDialog($scope, element)
  $scope.deletePackage = (element)-> deletePackage($scope, element)
  $scope.addCompatible = (element) -> addCompatible($scope, element)  
  $scope.removeCompatible = (element)-> removeCompatible($scope, element)
  $scope.addPartition = (element) -> addPartition($scope, element)  
  $scope.removePartition = (element) -> removePartition($scope, element)  

ModelsCreateCtrl.$inject = ['$scope', '$location', '$routeParams', 'Model']
ModelsEditCtrl.$inject = ['$scope', '$location', '$routeParams', 'Model']

submit = ($scope)->
  $scope.isLoading = true
  $scope.process_images()

process_images = ($scope)->
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

process_attachments = ($scope)->
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

real_submit = ($scope, type, Model)->
  model = 
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
      properties_attributes: $.extend({}, _.map(_.reject($scope.model.properties,(p)-> p._destroy), (p)->{key: p.key, value: p.value}))
      compatibles_attributes: $.extend([], _.map $scope.model.compatibles, (p)->{id: p.id})
      packages: _.map($scope.model.packages, (i)-> 
          id: i.id
          _destroy: i._destroy
          children: i.children
          inventory_code: i.inventory_code
          inventory_pool: i.inventory_pool
          is_borrowable: i.is_borrowable
          is_broken: i.is_broken
          is_incomplete: i.is_incomplete
          is_inventory_relevant: i.is_inventory_relevant
          last_check: i.last_check
          location: i.location
          name: i.name
          note: i.note
          price: i.price
          responsible: i.responsible
          user_name: i.user_name
        )
      is_package: _.find($scope.model.packages, ((i)->i.children? and i.children.length))?
      partitions_attributes: $.extend {}, _.map $scope.model.partitions, (p)->
        id: p.id
        quantity: p.quantity
        group_id: p.group.id
        inventory_pool_id: $scope.current_inventory_pool_id
        _destroy: p._destroy
  success = (response) ->
    if _.find($scope.model.packages, (p)-> not p.id?)?
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models/#{response.id}/edit"
    else
      window.location = "/backend/inventory_pools/#{$scope.current_inventory_pool_id}/models"
  error = (response) ->
    $scope.isLoading = false
    Notification.add_headline
      title: _jed('Error')
      text: response.data
      type: 'error'
  if type == 'save' then Model.save(model, success, error) else if type == 'update' then Model.update(model, success, error)

setFile = ($scope, element, file_type)->
  $scope.$apply ($scope) ->
    for file in element.files
      file.filename = file.name
      switch file_type
        when 1 then $scope.model.images.push file
        when 2 then $scope.model.attachments.push file

addAccessory = ($scope, element)->
  $scope.$apply ($scope) ->
    $scope.model.accessories.push {name: element.value, active: true}
    element.value = ""

removeImage = ($scope, element)->
  $scope.model.images = _.reject $scope.model.images, (image)-> image is element.file    

removeAttachment = ($scope, element)->
  $scope.model.attachments = _.reject $scope.model.attachments, (attachment)-> attachment is element.file

removeAccessory = ($scope, element)->
  $scope.model.accessories = _.reject $scope.model.accessories, (accessory)-> accessory is element.accessory

addProperty = ($scope)->
  $scope.model.properties.unshift({key: "", value: ""})
  setTimeout (-> $("input[name='key']:first").focus()), 100

removeProperty = ($scope, element)->
  $scope.model.properties = _.reject $scope.model.properties, (p)-> p is element.property

openPackageDialog = ($scope, element)-> 
  aPackage = if element? then element.package
  new App.EditPackageController
    package: aPackage
    saveCallback: (children, packageData)=> 
      if aPackage?
        $scope.$apply saveModifiedPackage($scope, aPackage, children, packageData)
      else
        $scope.$apply addPackage($scope, children, packageData)

saveModifiedPackage = ($scope, aPackage, children, packageData)->
  $.extend aPackage, packageData
  aPackage.children = children

addPackage = ($scope, children, aPackage)->
  $.extend aPackage, {
    inventory_code: "#{_jed("Prepackaged")} (#{_jed("not yet saved")})"
    children: children
  }
  $scope.model.packages.unshift aPackage

deletePackage = ($scope, element)->
  element.model.packages = _.reject element.model.packages, (p)-> element.package == p

addCompatible = ($scope, element) ->
  $scope.$apply ($scope) ->
    $scope.model.compatibles.push element.item unless _.find $scope.model.compatibles, (el_item)-> el_item.id == element.item.id

removeCompatible = ($scope, element)->
  $scope.model.compatibles = _.reject $scope.model.compatibles, (compatible)-> compatible is element.compatible

addPartition = ($scope, element)->
  $scope.$apply ($scope) ->
    partition = 
      group: element.item
      quantity: 1
    $scope.model.partitions.push partition unless _.find $scope.model.partitions, (p)-> p.group.id == element.item.id

removePartition = ($scope, element)->
  $scope.model.partitions = _.reject $scope.model.partitions, (p)-> p.group.id == element.partition.group.id

# exports
root = global ? window
root.ModelsCreateCtrl   = ModelsCreateCtrl
root.ModelsEditCtrl   = ModelsEditCtrl
