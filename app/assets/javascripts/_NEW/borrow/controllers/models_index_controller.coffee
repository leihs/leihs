class window.App.Borrow.ModelsIndexController extends Spine.Controller

  elements:
    "#model-list": "list"

  constructor: ->
    super
    @models = _.map @models, (m)=> new App.Model m
    @searchTerm = @params.search_term
    @reset = new App.Borrow.ModelsIndexResetController {el: @el.find("#reset-all-filter"), reset: @resetAllFilter, isResetable: @isResetable}
    @ipSelector = new App.Borrow.ModelsIndexIpSelectorController {el: @el.find("#ip-selector"), onChange: => do @resetAndFetchModels}
    @sorting = new App.Borrow.ModelsIndexSortingController {el: @el.find("#model-sorting"), onChange: => do @resetAndFetchModels}
    @search = new App.Borrow.ModelsIndexSearchController {el: @el.find("#model-list-search"), onChange: => do @resetAndFetchModels}
    @period = new App.Borrow.ModelsIndexPeriodController {el: @el.find("#period"), onChange: => do @periodChange}
    @pagination = new App.Borrow.ModelsIndexPaginationController {el: @list, onChange: (page)=> @fetchModels(page)}
    @tooltips = new App.Borrow.ModelsIndexTooltipController {el: @list}
    do @delegateEvents

  delegateEvents: =>
    super
    App.Availability.on "refresh", @render
    App.Model.on "ajaxSuccess", (e,status,xhr)=> @pagination.setData JSON.parse(xhr.getResponseHeader("X-Pagination"))

  periodChange: =>
    do @reset.validate
    @tooltips.tooltips = {}
    if @period.getPeriod()?
      do @loading
      do @fetchAvailability
    else
      App.Availability.records = {}
      do @render

  resetAndFetchModels: =>
    do @reset.validate
    do @loading
    App.Model.records = {}
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
    .done (models)=>
      @models = @models.concat _.map models, (m)=> new App.Model m
      if @period.getPeriod()? then do @fetchAvailability else do @render

  fetchAvailability: =>
    model_ids = if @currentStartDate == @period.getPeriod().start_date and @currentEndDate == @period.getPeriod().end_date
      _.map(_.reject(App.Model.all(), (m)->m.availabilities().all().length), (m)-> m.id)
    else
      _.keys App.Model.records
    @currentStartDate = @period.getPeriod().start_date
    @currentEndDate = @period.getPeriod().end_date
    App.Availability.fetch
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