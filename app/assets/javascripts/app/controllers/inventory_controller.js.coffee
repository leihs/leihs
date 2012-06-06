class InventoryController

  el: "#inventory"
  
  @fetcher
  @list
  @pagination
  @search
  @filter
  @responsibles
  @tabs
  @active_tab
  @current_page = 1
  
  constructor: ->
    @el = $(@el)
    @list = @el.find(".list")
    @loading = @list.find(">.loading")
    @pagination = @el.find(".pagination_container")
    @search = @el.find(".navigation .search input[type=text]")
    @filter = @el.find(".filter input[data-filter]")
    @responsibles = @el.find(".responsible select")
    @tabs = @el.find(".inlinetabs")
    do @delegateEvents
    do @fetch_responsibles
    do @fetch_inventory
    do @plugin
    
  plugin: ->
    do ListSearch.setup
    do @search.changed_after_input
    
  setup_pagination: (data)=>
    @pagination.html ""
    ListPagination.setup $.extend(data,{callback: @paginate})
  
  render_inventory: (data)=>
    @loading.detach()
    @list.find(">*:not(.navigation)").remove()
    @list.append $.tmpl "tmpl/line", data
    @list.find(".toggle[data-toggle_target]").expandable_line()
    
  setup_responsibles: (data)=>
    tmpl = $.tmpl "app/views/inventory/_responsibles", {responsibles: data}
    if @list.find(".select.responsible").length
      @list.find(".select.responsible").replaceWith tmpl
    else
      @list.find(".navigation .filter").prepend tmpl
    @list.find(".navigation select").custom_select
      postfix: "<div class='icon arrow down'></div>"
      text_handler: (text)-> Str.sliced_trunc(text, 22)
    @responsibles = @el.find(".responsible select")
    @responsibles.on "change", @fetch_inventory
  
  no_items_found: =>
    console.log "NO ITEMS FOUND" 
    @list.append $.tmpl "app/views/inventory/_no_entries_found"
  
  paginate: (page)=>
    @current_page = page+1
    do @fetch_inventory
    return false
  
  fetch_responsibles: =>
    $.ajax
      url: "/backend/inventory_pools/#{current_inventory_pool}/models.json"
      type: 'GET'
      data:
        responsibles: true 
      success: (data) => @setup_responsibles data.responsibles
  
  fetch_inventory: =>
    filter = {}
    @list.append @loading
    @fetcher.abort() if @fetcher?
    filter.flags = _.map @list.find(".filter input:checked"), (filter)-> $(filter).data("filter")
    responsible_id = @responsibles.find("option:selected").data "responsible_id"
    filter.responsible_id = responsible_id if responsible_id?
    query = if @search.val().length then @search.val() else undefined
    tab_data = @active_tab.data("tab") if @active_tab?
    console.log tab_data
    data = 
      page: @current_page
      filter: filter
      query: query
      with: 
        preset: "inventory"
    data = $.extend(data,tab_data) if tab_data?
    @fetcher = $.ajax
      url: "/backend/inventory_pools/#{current_inventory_pool}/models.json"
      type: 'GET'
      data: data
      success: (data) =>
        @render_inventory data.inventory.entries
        @setup_pagination data.inventory.pagination
        do @no_items_found unless data.inventory.entries.length
        
  delegateEvents: =>
    @filter.on "change", @fetch_inventory
    @search.on "changed_after_input", (e)=> do @fetch_inventory
    @search.closest("form").on "submit", (e)=>
      do e.preventDefault
      do @fetch_inventory
    @tabs.on "click", ".tab", (e)=>
      @active_tab = $(e.currentTarget)
      do e.preventDefault
      do @fetch_inventory

window.App.InventoryController = InventoryController
