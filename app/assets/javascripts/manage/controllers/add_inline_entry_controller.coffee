class window.App.AddInlineEntryController extends Spine.Controller

  events:
    "focus input[data-type='autocomplete']": "setupAutocomplete"

  elements:
    "input[data-type='autocomplete']": "input"
    ".list-of-lines": "list"

  setupAutocomplete: (groups) =>
    @input.autocomplete
      source: @source
      focus: => return false
      select: @select
      minLength: 0
    .data("autocomplete")._renderItem = (ul, item) => $(App.Render "views/autocomplete/element", item).data("item.autocomplete", item).appendTo(ul)
    @input.autocomplete("search")

  source: (request, response) => 
    @fetch(request.term).done (data)=>
      data = _.map data, (datum)=>
        label: datum.name
        record: App[@model].find datum.id
      response data

  fetch: (term)=>
    App[@model].ajaxFetch
      data: $.param
        search_term: term

  select: (e, ui)=>
    record = ui.item.record
    @input.autocomplete("destroy")
    @input.val("").blur()
    unless @list.find(@getExistingEntry(record)).length
      @list.prepend App.Render @templatePath, record, uid: App[@model].uid("uid")
    return false