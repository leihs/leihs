class window.App.ItemEditController extends Spine.Controller

  elements:
    "#flexible-fields": "flexibleFields"
    "#item-form": "itemForm"
    "input[name='copy']": "copyInput"

  events: 
    "click #item-save": "save"
    "click #item-save-and-copy": "saveAndCopy"

  constructor:->
    super
    @flexibleFieldsController = new App.ItemFlexibleFieldsController
      el: @flexibleFields
      itemData: @itemData
      itemType: @itemType
      writeable: true

  save: =>
    if @flexibleFieldsController.validate()
      @itemForm.submit()

  saveAndCopy: =>
    if @flexibleFieldsController.validate()
      @copyInput.attr "disabled", false
      @itemForm.submit()
