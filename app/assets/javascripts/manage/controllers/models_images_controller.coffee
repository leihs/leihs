#= require ./models_upload_controller
class window.App.ModelsImagesController extends App.ModelsUploadController

  constructor: ->
    super
    @type = "image"
    @templatePath = "manage/views/models/form/image_inline_entry"

  processNewFile: (template, file)=>
    reader = new FileReader()
    reader.onload = (e)=> template.find("img").attr "src", e.target.result
    reader.readAsDataURL file