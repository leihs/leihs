class window.App.SearchResultsController extends Spine.Controller

  elements: 
    ".list-of-lines": "list"

  constructor: ->
    super
    @additionalData = { accessRight: App.AccessRight, currentUserRole: App.User.current.role }
    @pagination = new App.ListPaginationController {el: @list, fetch: @_fetch}
    do @reset

  reset: =>
    @records = {}
    @list.html App.Render "manage/views/lists/loading"
    @_fetch 1, @list

  _fetch: (page, target)=>
    callback = _.after 2, => @render(target,@records[page], page, @additionalData)
    @fetch(page, target, callback).done (data, status, xhr) => 
      @pagination.set JSON.parse(xhr.getResponseHeader("X-Pagination"))
      records = (App[@model].find(datum.id) for datum in data)
      @records[page] = records
      do callback

  render: (target, data, page, additionalData)=>
    if page == 1 and (not data? or data.length == 0)
      target.html App.Render "manage/views/lists/no_results"
    else
      target.html App.Render @templatePath, data, additionalData
      @pagination.renderPlaceholders() if page == 1
