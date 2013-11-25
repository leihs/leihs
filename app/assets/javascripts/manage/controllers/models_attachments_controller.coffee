#= require ./models_upload_controller
class window.App.ModelsAttachmentsController extends App.ModelsUploadController

  constructor: ->
    super
    @type = "attachment"
    @templatePath = "manage/views/models/form/attachment_inline_entry"