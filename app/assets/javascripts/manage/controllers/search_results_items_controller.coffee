#= require ./search_results_controller
class window.App.SearchResultsItemsController extends App.SearchResultsController

  model: "Item"
  templatePath: "manage/views/items/line"

  fetch: (page, target, callback)=>
    @fetchItems(page).done (data)=>
      items = (App.Item.find datum.id for datum in data)
      @fetchModels(items).done =>
        @fetchCurrentItemLocation(items).done => do callback

  fetchItems: (page)=>
    App.Item.ajaxFetch
      data: $.param
        search_term: @searchTerm
        page: page

  fetchModels:(items) =>
    ids = _.uniq _.map items, (i)-> i.model_id
    return {done: (c)->c()} unless ids.length
    App.Model.ajaxFetch
      data: $.param
        ids: ids
        paginate: false
        include_package_models: true

  fetchCurrentItemLocation: (items)=>
    ids = _.map items, (i)-> i.id
    return {done: (c)->c()} unless ids.length
    App.CurrentItemLocation.ajaxFetch
      data: $.param
        ids: ids
        all: true
        paginate: false