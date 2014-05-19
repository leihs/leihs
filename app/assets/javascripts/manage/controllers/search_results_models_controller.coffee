#= require ./search_results_controller
class window.App.SearchResultsModelsController extends App.SearchResultsController

  model: "Model"
  templatePath: "manage/views/models/line"

  constructor: ->
    super
    new App.TimeLineController {el: @el}

  fetch: (page, target, callback)=>
    @fetchModels(page).done (data)=>
      models = (App[@model].find datum.id for datum in data)
      @fetchAvailability(models).done =>
        do callback

  fetchModels: (page)=>
    App[@model].ajaxFetch
      data: $.param
        search_term: @searchTerm
        type: @type
        page: page

  fetchAvailability: (models)=>
    ids = _.map models, (m)-> m.id
    return {done: (c)->c()} unless ids.length
    App.Availability.ajaxFetch
      url: App.Availability.url()+"/in_stock"
      data: $.param
        model_ids: ids
