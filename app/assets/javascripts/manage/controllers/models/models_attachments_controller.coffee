#= require ../shared/upload_controller

class window.App.ModelsAttachmentsController extends App.UploadController

  constructor: ->
    super
    @type = "attachment"
    @templatePath = "manage/views/models/form/attachment_inline_entry"
    @url = @model.url("upload/#{@type}")
