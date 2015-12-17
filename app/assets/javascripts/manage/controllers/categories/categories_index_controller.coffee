class window.App.CategoriesIndexController extends Spine.Controller

  elements:
    "#list": "list"

  constructor: ->
    super
    do @showLoading
    @fetchCategories().done =>
      @fetchCategoryLinks().done =>
        @renderList App.Category.roots()
    new App.CategoriesIndexExpandController {el: @el.find "#list"}
    @search = new App.ListSearchController {el: @el.find("#list-search"), reset: @resetAndRender}

  resetAndRender: =>
    @categories = {}
    do @showLoading

    if searchTerm = @search.term()
      @localSearch searchTerm
    else
      @renderList App.Category.roots()

  localSearch: (searchTerm) =>
    regex = new RegExp searchTerm, "i"
    @categories = _.filter App.Category.all(), (c) -> c.name.match(regex)
    @renderList @categories

  showLoading: =>
    @list.html App.Render "manage/views/lists/loading"

  fetchCategories: =>
    App.Category.ajaxFetch
      data: $.param
        include:
          'used?': true
    .done (data) =>
      @categories = (App.Category.find datum.id for datum in data)

  fetchCategoryLinks: =>
    App.CategoryLink.ajaxFetch().done (data) =>
      @categoryLinks = (App.CategoryLink.find datum.id for datum in data)

  renderList: (categories) =>
    @list.html App.Render "manage/views/categories/line", categories
