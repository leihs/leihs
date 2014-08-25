#= require ./category_controller

class window.App.NewCategoryController extends App.CategoryController

  save: =>
    $.post(App.Category.url(), @form.serializeArray()).done (data) =>
      @category.id = data.id
      do @updateUploadURL

  updateUploadURL: => @imagesController.url = @category.url("upload/image")
