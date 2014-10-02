#= require ../shared/form_with_upload_controller

class window.App.ModelsEditController extends App.FormWithUploadController

  elements:
    "input[name='model[manufacturer]']": "manufacturer"

  constructor: ->
    super
    new App.ModelsAllocationsController {el: @el.find("#allocations")}
    new App.ModelsCategoriesController {el: @el.find("#categories")}
    new App.ModelsAccessoriesController {el: @el.find("#accessories")}
    new App.ModelsCompatiblesController
      el: @el.find("#compatibles")
      customLabelFn: (datum) ->
        label = datum.product
        label = [label, datum.version].join(" ") if datum.version
        label
    new App.ModelsPropertiesController  {el: @el.find("#properties")}
    new App.ModelsPackagesController  {el: @el.find("#packages")} if @el.find("#packages").length

    @imagesController = new App.ImagesController
      el: @el.find("#images")
      url: @model.url("upload/image")

    @attachmentsController = new App.ModelsAttachmentsController  {el: @el.find("#attachments"), model: @model}
    new App.InlineEntryRemoveController {el: @el}
    do @setupManufacturer

  setupManufacturer:  =>
    @manufacturer.autocomplete
      source: @manufacturers
      minLength: 0
      delay: 0
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "views/autocomplete/element", item).data("value", item).appendTo(ul)
    @manufacturer.focus -> $(this).autocomplete("search")

  done: =>
    @imagesController.upload =>
      @attachmentsController.upload =>
        do @finish

  finish: =>
    if @imagesController.uploadErrors.length or @attachmentsController.uploadErrors.length
      @setupErrorModal(@model)
    else
      window.location = App.Inventory.url()+"?flash[success]=#{_jed('Model saved')}"

  save: => $.ajax
    url: @model.url()
    data: @form.serializeArray()
    type: "PUT"

  collectErrorMessages: =>
    @imagesController.uploadErrors.concat(@attachmentsController.uploadErrors).join(", ")
