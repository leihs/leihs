class window.App.ItemEditController extends App.FormWithUploadController

  elements:
    "#flexible-fields": "flexibleFields"
    "#form": "itemForm"
    "input[name='copy']": "copyInput"

  events:
    "click #item-save-and-copy": "submitCopy"
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
      callback: =>
        @attachmentsController = new App.ItemAttachmentsController {el: @el.find("#attachments")}

  save: =>
    if @flexibleFieldsController.validate()
      $.ajax
        url: @url
        data: @itemForm.serializeArray()
        type: @method
    else
      do @hideLoading

  done: (data) =>
    # depending if used in new or edit template
    # item is available from start or is created on save thus
    # have to be set and the upload url with the item id too
    @item ?= new App.Item(id: data.id) # using only id, as some other attribute makes problem
    @attachmentsController.setUrl(@item)

    @attachmentsController.upload =>
      @finish(data.redirect_url)

  finish: (redirectUrl = null) =>
    if @attachmentsController.uploadErrors.length
      @setupErrorModal(@item)
    else
      url = redirectUrl ? App.Inventory.url()
      window.location = "#{url}?flash[success]=#{_jed('Item saved')}"

  submit: (event, saveAction = @save) =>
    super(event, saveAction)

  submitCopy: (event) => @submit(event, @saveAndCopy)

  saveAndCopy: =>
    if @flexibleFieldsController.validate()
      @copyInput.prop "disabled", false
      $.ajax
        url: @url
        data: @itemForm.serializeArray()
        type: @method
    else
      do @hideLoading

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
