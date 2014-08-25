#= require ./add_inline_entry_controller.coffee
class window.App.CategoriesLinksController extends App.AddInlineEntryController

  constructor: ->
    super
    @model = "Category"
    @templatePath = "manage/views/categories/category_link_inline_entry"

  getExistingEntry: (record)=>
    @list.find("input[name*='parent_id'][value='#{record.id}']")

  source: (request, response) => 
    @fetch(request.term).done (data)=>
      if @category
        data = _.filter data, (datum) => datum.id != @category.id
      data = _.map data, (datum)=>
        label: datum.name
        record: App[@model].find datum.id
      response data

  select: (e, ui)=>
    record = ui.item.record
    @input.autocomplete("destroy")
    @input.val("").blur()
    unless @list.find(@getExistingEntry(record)).length
      @list.prepend App.Render @templatePath, record, {uid: App[@model].uid("uid"), label: @labelInput.val()}
    return false
