#= require ./form_with_upload_controller

class window.App.CategoryController extends App.FormWithUploadController

  constructor: ->
    super

    @imagesController = new App.ImagesController
      el: @el.find("#images")
      url: @category.url("upload/image")
      click: ->
        if @list.find(".line:not(.striked)").length or @uploadList.length
          alert _jed "Category can have only one image."
        else
          @el.find("input[type='file']").trigger "click"

    new App.InlineEntryRemoveController
      el: @el

    new App.CategoriesLinksController
      el: @el.find("#categories")
      labelInput: @el.find("#name-input")
      category: @category

  done: =>
    @imagesController.upload =>
      do @finish

  finish: =>
    if @imagesController.uploadErrors.length
      @setupErrorModal(@category)
    else
      window.location = App.Category.url()+"?flash[success]=#{_jed('Category saved')}"

  collectErrorMessages: =>
    @imagesController.uploadErrors.join(", ")
