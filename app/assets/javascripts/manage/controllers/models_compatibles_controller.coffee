#= require ./add_inline_entry_controller.coffee
class window.App.ModelsCompatiblesController extends App.AddInlineEntryController

  constructor: ->
    super
    @model = "Model"
    @templatePath = "manage/views/models/form/compatible_inline_entry"

  getExistingEntry: (record)=>
    @list.find("input[name*='[compatible_ids]'][value='#{record.id}']")
