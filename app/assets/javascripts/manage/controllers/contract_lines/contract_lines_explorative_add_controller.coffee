class window.App.ContractLinesExplorativeAddController extends Spine.Controller

  elements:
    "#categories": "categoriesContainer"
    "#models": "list"

  events: 
    "click [data-type='select']": "select"

  constructor: (data)->
    @startDate = data.startDate
    @endDate = data.endDate
    do @setupModal
    super
    @categoriesFilter = new App.CategoriesFilterController({el: @categoriesContainer, filter: @reset})
    @pagination = new App.ListPaginationController {el: @list, fetch: @fetch}
    do @reset

  setupModal: =>
    @el = $ App.Render "manage/views/contract_lines/explorative_add_dialog", {startDate: @startDate, endDate: @endDate}
    @modal = new App.Modal @el

  reset: =>
    @models = {}
    @list.html App.Render "manage/views/lists/loading"
    @fetch 1, @list

  fetch: (page, target)=>
    @fetchModels(page).done =>
      @fetchAvailability(page).done =>
        @render target, @models[page], page

  fetchModels: (page)=>
    App.Model.ajaxFetch
      data: $.param
        page: page
        category_id: @categoriesFilter.getCurrent()?.id
        used: true
        borrowable: true
        responsible_inventory_pool_id: App.InventoryPool.current.id
    .done (data, status, xhr) => 
      @pagination.set JSON.parse(xhr.getResponseHeader("X-Pagination"))
      models = (App.Model.find(datum.id) for datum in data)
      @models[page] = models

  fetchAvailability: (page)=>
    models = _.filter @models[page], (i)-> i.constructor.className == "Model"
    ids = _.map models, (m)-> m.id
    return {done: (c)->c()} unless ids.length
    App.Availability.ajaxFetch
      url: App.Availability.url()
      data: $.param
        model_ids: ids
        user_id: @contract.user_id

  render: (target, data, page)=> 
    if data?
      if data.length
        target.html App.Render "manage/views/models/explorative_add_line", data, {startDate: @startDate, endDate: @endDate, groupIds: @contract.user().groupIds}
        @pagination.renderPlaceholders() if page == 1
      else
        target.html App.Render "manage/views/lists/no_results"

  select: (e)=>
    target = $ e.currentTarget
    model = App.Model.find target.closest("[data-id]").data "id"
    @addModel model, @startDate, @endDate
    @modal.destroy true 
