class ExplorativeSearchDialogController

  constructor: (options)->
    do @setupDialog
    @list = @dialogContent.find(".list")
    @loading = @list.find(">.loading")
    @pagination = @dialog.find(".pagination_container")
    @modelSelectCallback = options.modelSelectCallback
    @customerId = options.customerId
    @inventoryPoolId = options.inventoryPoolId
    @startDate = options.startDate
    @endDate = options.endDate
    do @setupNavigation
    do @delegateEvents
    do @fetchModels

  setupDialog: =>
    @dialogContent = $.tmpl("app/views/explorative_search/dialog")
    @dialog = Dialog.add
      content: @dialogContent
      dialogClass: "large explorative-search-dialog"

  setupNavigation: =>
    @navigation = new App.ExplorativeSearchNavigationController
      button: @dialogContent.find(".explorative-search-toggle")
      el: @dialogContent.find(".explorative-navigation")

  delegateEvents: =>
    $(@navigation).on "navigation-changed", (e, currentCategoryId)=>
      @currentCategoryId = currentCategoryId
      Dialog.rescale(@dialog)
      do @fetchModels
    $(@navigation).on "navigation-fetched", (e)=> Dialog.rescale(@dialog)
    @list.on "click", "button.select-model", (e)=>
      modelId = $(e.currentTarget).closest("[data-id]").data "id"
      @modelSelectCallback modelId if @modelSelectCallback?
      @dialog.remove()

  fetchModels: =>
    @list.append @loading
    @ajax.abort() if @ajax?
    data = 
      page: @current_page
      per_page: 10
      category_id: @currentCategoryId
      for_current_inventory_pool: true
      with: 
        availability:
          user_id: @customerId
          inventory_pool_id: @inventoryPoolId
          start_date: @startDate
          end_date: @endDate
        preset: "modellist"
    @ajax = $.ajax
      url: "/backend/inventory_pools/#{currentInventoryPool.id}/models.json"
      type: 'GET'
      data: data
      success: (data) =>
        @renderModels data.entries
        @setupPagination data.pagination
        do @noItemsFound unless data.entries.length

  setupPagination: (data)=>
    @pagination.html ""
    ListPagination.setup $.extend(data,{callback: @paginate})
  
  renderModels: (data)=>
    @loading.detach()
    _.each data, (m)-> m.selectOnly = true
    @list.html $.tmpl "tmpl/line/add_model", data
    
  noItemsFound: => @list.append $.tmpl "app/views/inventory/_no_entries_found"
  
  paginate: (page)=>
    @current_page = page+1
    do @fetchModels
    return false
    
window.App.ExplorativeSearchDialogController = ExplorativeSearchDialogController