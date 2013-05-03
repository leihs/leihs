class ExplorativeSearchNavigationController

  constructor: (options)->
    @button = $(options.button)
    @el = $(options.el)
    @container = @el.find(".explorative-container")
    @searchInput = @el.find(".explorative-search")
    @way = if options.way? then options.way else []
    do @searchInput.changed_after_input
    do @delegateEvents
    do @fetch

  delegateEvents: =>
    @button.on "click", @toggleEl
    @container.on "click", ".explorative-entry", @navigate
    @el.on "click", ".explorative-current", @goBack
    @el.on "click", ".explorative-top", @goTop
    @searchInput.on "change changed_after_input", (e)=> @search($(e.currentTarget).val())

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
    if @searchResults?
      @searchResults
    else if typeof @current() == "string"
      @categoriesForTerm @current()
    else if @current()?
      @current().children
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

  search: (term)->
    return true if term == @term
    @term = term
    if term.length
      @way = [term]
      @searchResults = @categoriesForTerm term
    else
      @way = []
      @searchResults = undefined
    do @wayToURL
    do @render
      
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
      @searchInput.removeClass "hidden"
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
    @searchInput.val ""
    @searchResults = undefined
    do @navigationChanged
    
  goBack: =>
    do @way.pop
    @searchResults = undefined if _.isEmpty @way
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