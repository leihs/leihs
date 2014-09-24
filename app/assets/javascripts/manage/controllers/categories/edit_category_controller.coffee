#= require ./category_controller

class window.App.EditCategoryController extends App.CategoryController

  save: =>
    $.ajax
      url: @category.url()
      data: @form.serializeArray()
      type: "PUT"
