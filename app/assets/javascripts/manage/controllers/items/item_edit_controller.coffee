class window.App.ItemEditController extends Spine.Controller

  elements:
    "#flexible-fields": "flexibleFields"
    "#item-form": "itemForm"
    "input[name='copy']": "copyInput"

  events: 
    "click #item-save": "save"
    "click #item-save-and-copy": "saveAndCopy"
    "click #show-all-fields": "showAllFields"
    "click [data-type='remove-field']": "removeField"

  constructor:->
    super
    @flexibleFieldsController = new App.ItemFlexibleFieldsController
      el: @flexibleFields
      itemData: @itemData
      itemType: @itemType
      writeable: true
      hideable: true

  save: =>
    if @flexibleFieldsController.validate()
      @itemForm.submit()

  saveAndCopy: =>
    if @flexibleFieldsController.validate()
      @copyInput.prop "disabled", false
      @itemForm.submit()

  showAllFields: ->
    $.ajax
      url: "/manage/#{App.InventoryPool.current.id}/fields"
      type: "post"
      data:
        _method: "delete"
      success: (response) =>
        $(".hidden.field").removeClass("hidden")
        $("#show-all-fields").hide()

  removeField: (e)=>
    target = $(e.currentTarget).closest("[data-type='field']")
    $.ajax
      url: "/manage/#{App.InventoryPool.current.id}/fields/#{target.data("id")}"
      type: "post"
      success: (response) =>
        field = App.Field.find target.data("id")
        for child in field.children()
          target.closest("form").find("[name='#{child.getFormName()}']").closest("[data-type='field']").addClass("hidden")
        target.addClass("hidden")
        $("#show-all-fields").show()
