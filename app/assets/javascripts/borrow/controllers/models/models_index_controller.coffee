class window.App.ModelsIndexController extends Spine.Controller

  elements:
    "#model-list": "list"

  events:
    "click [data-create-order-line]": "createReservation"

  constructor: ->
    super
    @models = _.map @models, (m)=> new App.Model m
    @searchTerm = @params.search_term
    @reset = new App.ModelsIndexResetController {el: @el.find("#reset-all-filter"), reset: @resetAllFilter, isResetable: @isResetable}
    @ipSelector = new App.ModelsIndexIpSelectorController {el: @el.find("#ip-selector"), onChange: => do @resetAndFetchModels}
    @sorting = new App.ModelsIndexSortingController {el: @el.find("#model-sorting"), onChange: => do @resetAndFetchModels}
    @search = new App.ModelsIndexSearchController {el: @el.find("#model-list-search"), onChange: => do @resetAndFetchModels}
    @period = new App.ModelsIndexPeriodController {el: @el.find("#period"), onChange: => do @periodChange}
    @pagination = new App.ModelsIndexPaginationController {el: @list, onChange: (page)=> @fetchModels(page)}
    @tooltips = new App.ModelsIndexTooltipController {el: @list}
    do @delegateEvents

  delegateEvents: =>
    super
    App.PlainAvailability.on "refresh", @render
    App.Model.on "ajaxSuccess", (e,status,xhr)=> @pagination.setData JSON.parse(xhr.getResponseHeader("X-Pagination"))
    
  createReservation: (e)=>
    do e.preventDefault
    new App.ReservationsCreateController
      modelId: $(e.currentTarget).data("model-id")
      titel: _jed("Add to order")
      buttonText: _jed("Add")
    return false

  periodChange: =>
    do @reset.validate
    @tooltips.tooltips = {}
    if @period.getPeriod()?
      sessionStorage.startDate = @period.getPeriod().start_date
      sessionStorage.endDate = @period.getPeriod().end_date
      do @loading
      do @fetchAvailability
    else
      App.PlainAvailability.deleteAll()
      do @render

  resetAndFetchModels: =>
    do @reset.validate
    do @loading
    @models = []
    @pagination.page = 1
    @tooltips.tooltips = {}
    do @fetchModels

  isResetable: =>
    @search.is_resetable() or @sorting.is_resetable() or @period.is_resetable() or @ipSelector.is_resetable()

  resetAllFilter: =>
    @ipSelector.reset()
    @sorting.reset()
    @search.reset()
    @period.reset()
    @resetAndFetchModels()

  fetchModels: (page)=>
    $.extend @params, {inventory_pool_ids: @ipSelector.activeInventoryPoolIds()}
    $.extend @params, @sorting.getCurrentSorting()
    do @extendParamsWithSearchTerm
    params = _.clone @params
    if page?
      params.page = page
    App.Model.ajaxFetch
      data: $.param params
    .done (data)=>
      @models = @models.concat (App.Model.find(datum.id) for datum in data)
      if @period.getPeriod()? then do @fetchAvailability else do @render

  fetchAvailability: =>
    model_ids = _.map @models, (m)=> m.id
    @currentStartDate = @period.getPeriod().start_date
    @currentEndDate = @period.getPeriod().end_date
    App.PlainAvailability.fetch
      data: $.param
        start_date: @period.getPeriod().start_date
        end_date: @period.getPeriod().end_date
        model_ids: model_ids
        inventory_pool_ids: @ipSelector.activeInventoryPoolIds()

  render: =>
    @list.html App.Render "borrow/views/models/index/line", @models, {inventory_pool_ids: @ipSelector.activeInventoryPoolIds()}
    do @pagination.render

  loading: =>
    @list.html App.Render "borrow/views/models/index/loading"

  extendParamsWithSearchTerm: =>
    if @searchTerm? 
      if @search.getInputText().search_term?
        @params.search_term = "#{@searchTerm} #{@search.getInputText().search_term}"
      else
        @params.search_term = @searchTerm
    else 
      $.extend @params, @search.getInputText()
