class window.App.ListPaginationController extends Spine.Controller

  events:
    "inview .page:not(.fetched)": "inview"

  constructor: ->
    super
    @page = 1

  set: (data)=> 
    @totalCount = data.total_count
    @perPage = data.per_page

  totalPages: => Math.ceil(@totalCount / @perPage)

  renderPlaceholders: =>
    notLoadedPages = @totalPages() - @page
    if notLoadedPages > 0
      _.each _.range(1, notLoadedPages+1), (page)=> 
        page = page + @page
        template = $  App.Render("manage/views/lists/page", page, {entries: _.range(@perPage), page: page})
        @el.append template

  inview: (e)=>
    target = $(e.currentTarget)
    target.addClass "fetched"
    @page = target.data("page")
    @fetch @page, target
