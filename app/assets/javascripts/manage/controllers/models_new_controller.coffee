#= require ./models_edit_controller
class window.App.ModelsNewController extends App.ModelsEditController

  save: => 
    $.post(App.Model.url(), @form.serializeArray()).done (data)=>
      @model.id = data.id