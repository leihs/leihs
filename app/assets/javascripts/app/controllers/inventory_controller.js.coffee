class InventoryController

  el: "#inventory"
  
  @fetcher
  @list
  @pagination
  @search
  @filters
  @filter
  @responsibles
  @tabs
  @active_tab
  @current_page
  
  constructor: ->
    @el = $(@el)
    @filter = {}
    @list = @el.find(".list")
    @loading = @list.find(">.loading")
    @pagination = @el.find(".pagination_container")
    @search = @el.find(".navigation .search input[type=text]")
    @filters = @el.find(".filter input[data-filter]")
    @responsibles = @el.find(".responsible select")
    @tabs = @el.find(".inlinetabs")
    do @setup_state
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
    do @select_responsible
    @responsibles.on "change", @fetch_inventory
  
  select_responsible: =>
    if @filter.responsible_id?
      @responsibles.find("option").each (i,el)=> 
        if parseInt(@filter.responsible_id) == parseInt($(el).data("responsible_id"))
          $(el).attr("selected",true).change()
    else
      @responsibles.find("option:first").attr("selected",true).change()
    
  no_items_found: => @list.append $.tmpl "app/views/inventory/_no_entries_found"
  
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
    @list.append @loading
    @fetcher.abort() if @fetcher?
    @filter.flags = _.map @list.find(".filter input:checked"), (filter)-> $(filter).data("filter")
    responsible_id = @responsibles.find("option:selected").data("responsible_id")
    @filter.responsible_id = responsible_id if responsible_id?
    query = if @search.val().length then @search.val() else undefined
    tab_data = @active_tab.data("tab") if @active_tab?
    data = 
      page: @current_page
      filter: @filter
      query: query
      with: 
        preset: "inventory"
    data = $.extend(data,tab_data) if tab_data
    @fetcher = $.ajax
      url: "/backend/inventory_pools/#{current_inventory_pool}/models.json"
      type: 'GET'
      data: data
      success: (data) =>
        @render_inventory data.inventory.entries
        @setup_pagination data.inventory.pagination
        do @no_items_found unless data.inventory.entries.length
    do @save_state
  
  setup_state: =>
    state = do @read_state
    @current_page = if state.page? then state.page else undefined 
    if state.borrowable? or state.retired?
      tab_state = if state.borrowable? then {borrowable: state.borrowable} else {retired: state.retired}
      @tabs.find(".active").removeClass "active"
      $.each tab_state, (k,v)-> tab_state[k] = (v=="true")
      _.find @tabs.find(".tab"), (tab)=>
        if JSON.stringify($(tab).data("tab")) == JSON.stringify(tab_state)
          $(tab).addClass("active")
          @active_tab = $(tab)
    if state.flags?
      @filters.each (i,el)=> $(el).attr "checked", _.include(state.flags, $(el).data("filter"))
    if state.query? then @search.val(state.query) else @search.val("")
    @filter.responsible_id = if state.responsible_id? then state.responsible_id else undefined
    do @select_responsible
  
  read_state: =>
    state_as_array = window.location.hash.replace(/^#\//, "").split("/")
    state = {}
    last_state = undefined
    $.each state_as_array, (i, el)-> if (i % 2) then state[last_state] = el else last_state = el
    state.flags = state.flags.split(",") if state.flags?
    return state
   
  pop_state: =>
    return true if window.location.hash.replace(/^#/, "") == @stringify_state(@get_state())
    do @setup_state
    do @fetch_inventory
    
  save_state: =>
    state = do @get_state
    stringified_state = @stringify_state state
    if window.location.hash.replace(/^#/, "") != stringified_state 
      history.pushState state, document.title, "#{window.location.href.replace(/\/+#.*?$/, "")}/##{stringified_state}"
  
  get_state: =>
    state = {}
    state.page = @current_page
    state.query = @search.val() if @search.val().length
    state.tab = @active_tab.data("tab") if @active_tab?
    state.responsible_id = @filter.responsible_id if @filter.responsible_id
    state.flags = @filter.flags.join(",") if @filter.flags.length
    return state
  
  stringify_state: (state)=>
    stringified_state = ""
    $.each state, (k,v)->
      if v? and typeof(v) == "object"
        $.each v, (k,v)-> stringified_state += "/#{k}/#{v}"
      else if v?  
        stringified_state += "/#{k}/#{v}"
    return stringified_state
          
  delegateEvents: =>
    $(window).on "popstate", @pop_state
    @filters.on "change", =>
      delete @current_page
      do @fetch_inventory
    @search.on "changed_after_input", (e)=>
      delete @current_page
      do @fetch_inventory
    @search.closest("form").on "submit", (e)=>
      delete @current_page 
      do e.preventDefault
      do @fetch_inventory
    @tabs.on "click", ".tab", (e)=>
      delete @current_page
      @active_tab = $(e.currentTarget)
      do e.preventDefault
      do @fetch_inventory

window.App.InventoryController = InventoryController
