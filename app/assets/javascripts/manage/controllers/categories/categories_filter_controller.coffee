class window.App.CategoriesFilterController extends Spine.Controller

  elements:
    "#category-list": "list"
    "#category-root": "rootContainer"
    "#category-current": "currentContainer"
    "#category-search": "input"

  events:
    "click [data-type='category-filter']": "clickCategory"
    "click [data-type='category-root']": "goRoot"
    "click [data-type='category-current']": "goBack"
    "preChange #category-search": "search"

  constructor: ->
    super
    @categoryPath = []
    @searchTerm = ""
    @fetchCategories().done => do @render
    @fetchCategoryLinks().done => do @render
    @input.preChange()

  fetchCategories: =>
    App.Category.ajaxFetch().done (data)=> 
      @categories = (App.Category.find datum.id for datum in data)

  fetchCategoryLinks: =>
    App.CategoryLink.ajaxFetch().done (data)=>
      @categoryLinks = (App.CategoryLink.find datum.id for datum in data)

  render: (category)=>
    categories = if category?
        category.children()
      else if @categories? and @categoryLinks?
        @roots ?= App.Category.roots() 
    @renderList categories if categories?
    do @renderRoot
    do @renderLast

  renderList: (categories)=>
    @list.html App.Render "manage/views/categories/filter_list_entry", categories
  
  renderRoot: =>  
    return false if @searchTerm.length
    if @getRoot()?
      @rootContainer.html App.Render "manage/views/categories/filter_list_root", @getRoot()
    else
      @rootContainer.html ""

  renderLast: =>
    if @getCurrent()?
      @currentContainer.html App.Render "manage/views/categories/filter_list_current", @getCurrent()
    else
      @currentContainer.html ""

  renderSearch: (searchTerm, results)=>
    @rootContainer.html App.Render "manage/views/categories/filter_list_search", {search_term: @input.val()}
    @currentContainer.html ""
    if results.length
      @list.html App.Render "manage/views/categories/filter_list_entry", results
    else
      @list.html ""

  clickCategory: (e)=>
    target = $ e.currentTarget
    category = App.Category.find target.data "id"
    @select category

  getRoot: => _.first @categoryPath if @categoryPath.length > 1

  getCurrent: => _.last @categoryPath if @categoryPath.length > 0

  select: (category)=>
    @categoryPath.push category
    @render category
    do @filter if @filter?

  goRoot: (e)=>
    @categoryPath = @categoryPath.splice(0,1)
    @render @categoryPath[0]
    do @filter if @filter?

  goBack: (e)=>
    @categoryPath = if @categoryPath.length > 1
        @categoryPath.splice 0, @categoryPath.length-1
      else
        @categoryPath = []
    category = _.last @categoryPath if @categoryPath.length > 1
    if @searchTerm.length and @categoryPath.length == 0
      do @search
    else
      @render category
    do @filter if @filter?

  search: =>
    @searchTerm = @input.val()
    if @searchTerm.length
      results = _.filter App.Category.all(), (c)=> c.name.match RegExp(@searchTerm,"i")
      @renderSearch @searchTerm, results
    else
      do @render