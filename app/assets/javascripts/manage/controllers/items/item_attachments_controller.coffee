#= require ../shared/upload_controller

class window.App.ItemAttachmentsController extends App.UploadController

  constructor: ->
    super
    @type = "attachment"
    @templatePath = "manage/views/items/fields/writeable/partials/attachment_inline_entry"
    new App.InlineEntryRemoveController {el: @el}

  setUrl: (item) => @url = item.url("upload/#{@type}")
