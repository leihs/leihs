class window.App.SearchTopbarController extends Spine.Controller

  elements:
    "input#search_term": "input"
    "i": "icon"
    ".addon": "addon"
    "#search-autocomplete": "autocompleteContainer"
    "form": "form"

  events:
    "preChange input": "search"
    "blur input": "close"
    "focus input": "open"
    "submit form": "submit"

  constructor: ->
    super
    @input.preChange()

  search: =>
    return false unless @input.val().length
    do @loading
    (do @fetchModels).done (data)=>
      @models = (App.Model.find(datum.id) for datum in data)
      do @finished
      do @autocomplete

  loading: =>
    do @icon.detach
    @addon.html App.Render "views/loading", {size: "micro"}

  finished: => @addon.html @icon

  open: =>
    @autocompleteContainer.show()
    do @search

  close: =>
    _.delay (=> @autocompleteContainer.hide()), 200

  keydown: (e)=>
    if $("*:focus").length == 0 and 
    String.fromCharCode(e.which).length and 
    not _.include([224, 16, 17, 18, 32, 13, 37, 38, 39, 40, 8, 9, 20, 91, 93, 27], e.which) and
    e.metaKey == false
      @input.val("") and @input.focus() 

  fetchModels: =>
    params = {}
    params.search_term = @input.val()
    arch_term = @input.val()
    params.per_page = 6
    App.Model.ajaxFetch
      data: $.param params

  autocomplete: =>
    @input.autocomplete
      appendTo: @autocompleteContainer
      source: (request, response)=> 
        data = _.map @models, (m)=>
          m.value = m.name
          m
        data.push {value: request, searchAll: true}
        response data
      focus: => return false
      select: (e, ui)=>
        if ui.item.searchAll?
          do @form.submit
          return false
        else
          window.location = "/borrow/models/#{ui.item.id}"
          return false
    .data("uiAutocomplete")._renderItem = (ul, item)=>
      if item.searchAll?
        showAll = $(App.Render("borrow/views/search/autocomplete/show_all")).data("value", item).appendTo(ul)
      else
        $(App.Render "borrow/views/search/autocomplete/model", item).data("value", item).appendTo(ul)
    @input.autocomplete("search")

  submit: (e)=>
    unless @input.val().length
      e.preventDefault()
      return false
