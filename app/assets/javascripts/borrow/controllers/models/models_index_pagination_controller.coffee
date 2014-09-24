class window.App.ModelsIndexPaginationController extends Spine.Controller

  events:
    "inview .page:not(.fetched)": "pageInview"

  constructor: ->
    super
    @setData @el.data("pagination")
    @page = @el.data("pagination").page
    do @render

  setData: (data)=> 
    @totalCount = data.total_count
    @perPage = data.per_page

  totalPages: => Math.ceil(@totalCount / @perPage)

  render: =>
    notLoadedPages = @totalPages() - @page
    if notLoadedPages > 0
      _.each _.range(1, notLoadedPages+1), (page)=> 
        page = page + @page
        template = $  App.Render("borrow/views/models/index/page", page, {entries: _.range(@perPage), page: page})
        @el.append template

  pageInview: (e)=>
    pageEl = $(e.currentTarget)
    pageEl.addClass "fetched"
    @page = pageEl.data("page")
    @onChange @page