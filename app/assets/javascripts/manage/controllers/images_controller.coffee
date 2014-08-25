#= require ./upload_controller
class window.App.ImagesController extends App.UploadController

  templatePath: "manage/views/templates/upload/image_inline_entry"

  constructor: ->
    super

  processNewFile: (template, file)=>
    reader = new FileReader()
    reader.onload = (e)=> template.find("img").attr "src", e.target.result
    reader.readAsDataURL file
