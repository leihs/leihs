class window.App.ModelsEditController extends Spine.Controller

  elements:
    "#model-form": "form"
    "#model-save": "saveButton"

  events:
    "click #model-save": "submit"
    "submit #model-form": "preventDefaultSubmit"

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
    @imagesController = new App.ModelsImagesController  {el: @el.find("#images"), model: @model}
    @attachmentsController = new App.ModelsAttachmentsController  {el: @el.find("#attachments"), model: @model}
    new App.InlineEntryRemoveController {el: @el}

  preventDefaultSubmit: (e)=> e.preventDefault()

  submit: =>
    do @showLoading
    @save()
    .fail (e)=>
      @showError e.responseText
      do @hideLoading
    .done => 
      @imagesController.upload =>
        @attachmentsController.upload =>
          do @finish

  showLoading: =>
    loadingTemplate = $ App.Render "views/loading", {size: "micro"}
    @saveButton.data "origin", @saveButton.html()
    @saveButton.html loadingTemplate
    @saveButton.attr "disabled", true

  hideLoading: =>
    @saveButton.html @saveButton.data "origin"
    @saveButton.attr "disabled", false

  finish: =>
    if @imagesController.uploadErrors.length or @attachmentsController.uploadErrors.length
      do @setupErrorModal
    else
      window.location = App.Inventory.url()+"?flash[success]=#{_jed('Model saved')}"

  setupErrorModal: =>
    errors = @imagesController.uploadErrors.concat(@attachmentsController.uploadErrors).join(", ")
    tmpl = App.Render "manage/views/models/upload_errors_dialog", {errors: errors, model: @model}
    modal = new App.Modal tmpl
    modal.undestroyable()

  save: => $.ajax
    url: @model.url()
    data: @form.serializeArray()
    type: "PUT"

  showError: (text)=>
    App.Flash
      type: "error"
      message: text
