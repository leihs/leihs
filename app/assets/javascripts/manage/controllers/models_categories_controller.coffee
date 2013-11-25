#= require ./add_inline_entry_controller.coffee
class window.App.ModelsCategoriesController extends App.AddInlineEntryController

  constructor: ->
    super
    @model = "Category"
    @templatePath = "manage/views/models/form/category_inline_entry"

  getExistingEntry: (record)=>
    @list.find("input[name='model[category_ids][]'][value='#{record.id}']")
