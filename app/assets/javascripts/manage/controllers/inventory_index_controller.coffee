class window.App.InventoryIndexController extends Spine.Controller

  elements:
    "#inventory": "list"
    "#csv-export": "exportButton"
    "#categories": "categoriesContainer"
    "[data-filter]": "filterElement"

  events: 
    "click #categories-toggle": "toggleCategories"

  constructor: ->
    super
    @pagination = new App.ListPaginationController {el: @list, fetch: @fetch}
    @search = new App.ListSearchController {el: @el.find("#list-search"), reset: @reset}
    @tabs = new App.ListTabsController {el: @el.find("#list-tabs"), reset: @reset, callback: @toggleFiltersVisibility}
    @filter = new App.ListFiltersController {el: @filterElement, reset: @reset}
    new App.TimeLineController {el: @el}
    new App.InventoryExpandController {el: @el}
    @exportButton.data "href", @exportButton.attr("href")
    do @reset

  reset: =>
    @inventory = {}
    _.invoke [App.Inventory, App.Item, App.License, App.Model, App.Software, App.Option], -> this.deleteAll()
    do @updateExportButton
    @list.html App.Render "manage/views/lists/loading"
    @fetch 1, @list

  updateExportButton: =>
    data = @getData()
    data.type = "license" if data.software # if we are in the software list, we actually want to export the licenses
    data.search_term = @search.term() if @search.term()?.length
    @exportButton.attr "href", URI(@exportButton.data("href")).query(data).toString()

  fetch: (page, target)=>
    @fetchInventory(page).done =>
      @fetchAvailability(page).done =>
        @fetchItems(page).done =>
          @fetchLicenses(page).done =>
            @render target, @inventory[page], page

  fetchInventory: (page)=>
    App.Inventory.ajaxFetch
      data: $.param $.extend @getData(),
        page: page
        search_term: @search.term()
        category_id: @categoriesFilter?.getCurrent()?.id
        sort: "name"
        order: "ASC"
    .done (data, status, xhr) => 
      @pagination.set JSON.parse(xhr.getResponseHeader("X-Pagination"))
      inventory = (App.Inventory.find(datum.id).cast() for datum in data)
      @inventory[page] = inventory

  fetchAvailability: (page)=>
    models = _.filter @inventory[page], (i)-> _.contains ["Model", "Software"], i.constructor.className
    ids = _.map models, (m)-> m.id
    return {done: (c)->c()} unless ids.length
    App.Availability.ajaxFetch
      url: App.Availability.url()+"/in_stock"
      data: $.param
        model_ids: ids

  fetchItems: (page)=>
    models = _.filter @inventory[page], (i) -> i.constructor.className == "Model"
    ids = _.map models, (m)-> m.id
    return {done: (c)->c()} unless ids.length
    App.Item.ajaxFetch
      data: $.param $.extend @getData(),
        model_ids: ids
        paginate: false
        search_term: @search.term()
        all: true

  fetchLicenses: (page)=>
    software = _.filter @inventory[page], (i) -> i.constructor.className == "Software"
    ids = _.map software, (s)-> s.id
    return {done: (c)->c()} unless ids.length
    App.License.ajaxFetch
      data: $.param $.extend @getData(),
        model_ids: ids
        paginate: false
        search_term: @search.term()
        all: true

  getData: => _.clone $.extend @tabs.getData(), @filter.getData()

  render: (target, data, page)=> 
    if data?
      if data.length
        target.html App.Render "manage/views/inventory/line", data
        @pagination.renderPlaceholders() if page == 1
      else
        target.html App.Render "manage/views/lists/no_results"

  toggleCategories: =>
    @categoriesFilter = new App.CategoriesFilterController({el: @categoriesContainer, filter: @reset}) unless @categoriesFilter?
    if @categoriesContainer.hasClass "hidden"
      do @openCategories
    else 
      do @closeCategories

  openCategories: =>
    @list.addClass "col4of5"
    @categoriesContainer.addClass("col1of5").removeClass("hidden")

  closeCategories: =>
    @list.removeClass "col4of5"
    @categoriesContainer.removeClass("col1of5").addClass("hidden")

  toggleFiltersVisibility: =>
    if @tabs.getData().type == "option"
      @filterElement.addClass "hidden"
      @filter.ignoreData = true
    else
      @filterElement.removeClass "hidden"
      @filter.ignoreData = false
