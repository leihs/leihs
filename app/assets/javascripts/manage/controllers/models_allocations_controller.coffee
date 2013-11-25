#= require ./add_inline_entry_controller.coffee
class window.App.ModelsAllocationsController extends App.AddInlineEntryController

  constructor: ->
    super
    @model = "Group"
    @templatePath = "manage/views/models/form/allocation_inline_entry"

  getExistingEntry: (record)=>
    @list.find("input[name*='[group_id]'][value='#{record.id}']")