#= require ./search_results_controller
class window.App.SearchResultsOptionsController extends App.SearchResultsController

  model: "Option"
  templatePath: "manage/views/options/line"

  constructor: ->
    super
    new App.TimeLineController {el: @el}

  fetch: (page, target, callback)=>
    @fetchOptions(page).done (data)=>
      options = (App.Option.find datum.id for datum in data)
      do callback

  fetchOptions: (page)=>
    App.Option.ajaxFetch
      data: $.param
        search_term: @searchTerm
        page: page
