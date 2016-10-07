#= require ./search_results_controller
class window.App.SearchResultsItemsController extends App.SearchResultsController

  model: "Item"
  dependingOnModel: "Model"
  templatePath: "manage/views/items/line"
  type: "item"

  fetch: (page, target, callback)=>
    @fetchItems(page).done (data)=>
      items = (App[@model].find datum.id for datum in data)
      @fetchModels(items).done =>
        @fetchCurrentItemLocation(items).done => do callback

  fetchItems: (page)=>
    App[@model].ajaxFetch
      data: $.param
        search_term: @searchTerm
        type: @type
        page: page
        current_inventory_pool: false

  fetchModels:(items) =>
    ids = _.uniq _.map items, (i)-> i.model_id
    return {done: (c)->c()} unless ids.length
    App[@dependingOnModel].ajaxFetch
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
        current_inventory_pool: false
