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
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "views/autocomplete/element", item).data("value", item).appendTo(ul)
    @input.autocomplete("search")

  source: (request, response) => 
    @fetch(request.term).done (data)=>
      data = _.map data, (datum)=>
        label: datum.name
        record: App[@model].find datum.id
      response data if @input.is(":focus")

  fetch: (term)=>
    App[@model].ajaxFetch
      data: $.param
        search_term: term

  select: (e, ui)=>
    record = ui.item.record
    @input.val("").blur()
    @input.autocomplete("destroy")
    unless @list.find(@getExistingEntry(record)).length
      @list.prepend App.Render @templatePath, record, uid: App[@model].uid("uid")
    e.preventDefault()
    return false