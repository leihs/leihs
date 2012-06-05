class InventoryController

  el: "#inventory"
  
  @fetcher
  @list
  @pagination
  @current_page = 1
  
  constructor: ->
    @el = $(@el)
    @list = @el.find(".list")
    @loading = @list.find(">.loading")
    @pagination = @el.find(".pagination_container")
    do @delegateEvents
    do @fetch
    do @plugin
    
  plugin: ->
    do ListSearch.setup
    
  setup_pagination: (data)=>
    @pagination.html ""
    ListPagination.setup $.extend(data,{callback: @paginate})
  
  render_inventory: (data)=>
    @loading.detach()
    @list.find(".line:not(.navigation)").remove()
    @list.append $.tmpl "tmpl/line", data
    @list.find(".toggle[data-toggle_target]").expandable_line()
    
  render_responsibles: (data)=>
    tmpl = $.tmpl "app/views/inventory/_responsibles", {responsibles: data}
    if @list.find(".select.responsible").length
      @list.find(".select.responsible").replaceWith tmpl
    else
      @list.find(".navigation .filter").prepend tmpl
    @list.find(".navigation select").custom_select
      postfix: "<div class='icon arrow down'></div>"
      text_handler: (text)-> Str.sliced_trunc(text, 22)
  
  paginate: (page)=>
    @current_page = page+1
    do @fetch
    return false
  
  fetch: =>
    @list.append @loading
    @fetcher.abort() if @fetcher?
    filter = _.map @list.find(".filter input:checked"), (filter)-> $(filter).data("filter")
    @fetcher = $.ajax
      url: "/backend/inventory_pools/#{current_inventory_pool}/models.json"
      type: 'GET'
      data:
        page: @current_page
        filter: filter
        with: 
          preset: "inventory"
      success: (data) =>
        @render_inventory data.inventory.entries
        @setup_pagination data.inventory.pagination
        @render_responsibles data.responsibles
        
  delegateEvents: =>
    @el.find(".filter input[data-filter]").on "change", @fetch

window.App.InventoryController = InventoryController
