class ModelsController

  el: "#models"
  
  constructor: (options)->
    @el = $(@el)
    @filter = {}
    @list = @el.find("#modellist")
    @loading = @list.find(">.loading")
    @pagination = @el.find(".pagination_container")
    @search = @el.find(".navigation .search input[type=text]")
    @filters = @el.find(".filter input[data-filter]")
    @tabs = @el.find(".inlinetabs")
    @navigation = options.navigation if options.navigation?
    @currentCategoryId = if options.currentCategoryId? then options.currentCategoryId else undefined
    do @setup_state
    do @delegateEvents
    do @fetch_models
    do @plugin
    
  plugin: ->
    do ListSearch.setup
    do @search.changed_after_input
    
  setup_pagination: (data)=>
    @pagination.html ""
    ListPagination.setup $.extend(data,{callback: @paginate})
  
  render_models: (data)=>
    @loading.detach()
    @list.find(">*:not(.navigation)").remove()
    @list.append $.tmpl "tmpl/line", data
    @list.find(".toggle[data-toggle_target]").expandable_line()
    
  no_items_found: => @list.append $.tmpl "app/views/inventory/_no_entries_found"
  
  paginate: (page)=>
    @current_page = page+1
    do @fetch_models
    return false
  
  fetch_models: =>
    @list.append @loading
    @fetcher.abort() if @fetcher?
    @filter.flags = _.map @list.find(".filter input:checked"), (filter)-> $(filter).data("filter")
    @query = if @search.val().length then @search.val() else undefined
    @tab_data = @active_tab.data("tab") if @active_tab?
    data = 
      page: @current_page
      filter: @filter
      query: @query
      category_id: @currentCategoryId
      with: 
        preset: "modellist"
    data = $.extend(data,@tab_data) if @tab_data
    @fetcher = $.ajax
      url: "/backend/inventory_pools/#{currentInventoryPool.id}/models.json"
      type: 'GET'
      data: data
      success: (data) =>
        @render_models data.entries
        @setup_pagination data.pagination
        do @no_items_found unless data.entries.length
    do @save_state

##   
# TODO outsource to a history state module (browser navigation)
  
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
    else
      @tabs.find(".active").removeClass "active"
      @active_tab = @tabs.find(".tab:first")
      @active_tab.addClass("active")
    if state.flags?
      @filters.each (i,el)=> $(el).attr "checked", _.include(state.flags, $(el).data("filter"))
    else
      @filters.each (i,el)=> $(el).attr "checked", false
    if state.query? then @search.val(state.query) else @search.val("")
  
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
    do @fetch_models
    
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
      do @fetch_models
    @search.on "changed_after_input", (e)=>
      delete @current_page
      do @fetch_models
    @search.closest("form").on "submit", (e)=>
      delete @current_page 
      do e.preventDefault
      do @fetch_models
    @tabs.on "click", ".tab", (e)=>
      delete @current_page
      @search.val("") if not $(e.currentTarget).data("tab")? and not @active_tab.data("tab")?
      @active_tab = $(e.currentTarget)
      do e.preventDefault
      do @fetch_models
    $(@navigation).on "navigation-changed", (e, currentCategoryId)=>
      @currentCategoryId = currentCategoryId
      do @fetch_models

window.App.ModelsController = ModelsController
