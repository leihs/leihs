class ExplorativeSearchNavigationController

  constructor: (options)->
    @button = $(options.button)
    @el = $(options.el)
    @container = @el.find(".explorative-container")
    @searchInput = @el.find(".explorative-search")
    @navigationHeader = @el.find(".explorative-header")
    @clearIcon = @navigationHeader.find(".clear.icon")
    @way = if options.way? then options.way else []
    do @setupSearch
    do @searchInput.changed_after_input
    do @delegateEvents
    do @fetch

  delegateEvents: =>
    @button.on "click", @toggleEl
    @container.on "click", ".explorative-entry", @navigate
    @el.on "click", ".explorative-current", @goBack
    @el.on "click", ".explorative-top", @goTop
    @searchInput.on "change changed_after_input", (e)=> @search($(e.currentTarget).val())
    @clearIcon.on "click", @clearSearch

  current: -> _.last(@way)

  top: -> _.first(@way)

  find: (id)->
    found = undefined
    searchRecursively = (categories, id)=>
      for category in categories
        do (category) =>
          found = category if (category.id == id)
          return if found?
          searchRecursively(category.children, id) if category.children.length
    searchRecursively @categories, id
    return found

  currentChildren: =>
    if @current()? and typeof @current() != "string"
      @current().children
    else if @searchResults?
      @searchResults
    else if @searchInput.val().length
      @categoriesForTerm @current()
    else
      @categories

  categoriesForTerm: (term)=>
    results = {}
    searchRecursively = (categories)=>
      for category in categories
        do (category) =>
          searchRecursively(category.children) if category.children.length
          results[category.id] = category if category.name.match(new RegExp(term, "i"))?
    searchRecursively @categories
    @searchResults = _.sortBy results, (r)->r.name
    return @searchResults

  setupSearch: =>
    if @way.length and typeof @way[0] == "string"
      @searchInput.val(@way[0]) 
      @clearIcon.removeClass "hidden"

  search: (term)->
    @clearIcon.removeClass "hidden"
    if term.length
      @way = [term]
      @searchResults = @categoriesForTerm term
    else
      @way = []
      @searchResults = undefined
    do @wayToURL
    do @render

  clearSearch: =>
    @searchInput.val ""
    @searchResults = undefined
    @clearIcon.addClass "hidden"
    @way = []
    do @navigationChanged
      
  toggleEl: =>
    uri = URI window.location.href
    if @el.is ".open"
      @el.removeClass "open"
      @button.removeClass "active"
      uri.removeQuery("navigation")
    else
      @el.addClass "open"
      @button.addClass "active"
      @searchInput.focus()
      uri.removeQuery("navigation").addQuery "navigation", "true"
    window.history.replaceState uri._parts, document.title, uri.toString()

  wayToURL: =>
    uri = URI window.location.href
    uri.removeQuery("way[]").addQuery "way[]", _.map @way, (c)->
      if (typeof c is "string") then c else c.id
    window.history.replaceState uri._parts, document.title, uri.toString()

  fetch: =>
    App.Category.fetch (categories)=>
      @categories = categories
      @navigationHeader.removeClass "hidden"
      do @reconstructWay if not _.isEmpty(@way) and _.any(@way, (w)->typeof w == "number")
      do @render
      $(@).trigger "navigation-fetched"
      @el.trigger "navigation-fetched"

  reconstructWay: =>
    @way = _.map @way, (id) => 
      if typeof id == "number"
        @find(id)
      else 
        id

  render: =>
    @container.html $.tmpl "app/views/explorative_search/container",
      categories: @currentChildren()
      current: @current()
      top: @top()

  navigate: (e)=>
    target = $(e.currentTarget)
    node = target.tmplItem().data
    @way.push node
    do @navigationChanged
    
  goBack: =>
    return false if typeof @current() == "string"
    do @way.pop
    @searchResults = undefined if _.isEmpty(@way) and @searchInput.val().length == 0
    do @navigationChanged

  goTop: =>
    @way = @way.slice(0,1)
    do @navigationChanged

  navigationChanged: =>
    currentCategoryId = @current().id if @current()? and @current().id?
    do @wayToURL
    do @render
    $(@).trigger "navigation-changed", currentCategoryId
    @el.trigger "navigation-changed", currentCategoryId

window.App.ExplorativeSearchNavigationController = ExplorativeSearchNavigationController