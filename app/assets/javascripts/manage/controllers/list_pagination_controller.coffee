class window.App.ListPaginationController extends Spine.Controller

  events:
    "inview .page:not(.fetched)": "inview"

  set: (data)=>
    @totalCount = data.total_count
    @perPage = data.per_page

  totalPages: => Math.ceil(@totalCount / @perPage)

  renderPlaceholders: =>
    notLoadedPages = @totalPages() - 1
    if notLoadedPages > 0
      _.each _.range(1, notLoadedPages+1), (page)=> 
        page = page + 1
        template = $  App.Render("manage/views/lists/page", page, {entries: _.range(@perPage), page: page})
        @el.append template

  inview: (e)=>
    target = $(e.currentTarget)
    target.addClass "fetched"
    @fetch target.data("page"), target
