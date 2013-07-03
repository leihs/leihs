class window.App.UsersController

  constructor: (options) ->
    @el = $(options.el)
    @pagination = $(".pagination_container")
    @setupPagination(options.pagination)
    @searchInput = options.searchInput.changed_after_input()
    do @delegateEvents

  setupPagination: (data) =>
    @pagination.replaceWith "<div class='pagination_container'></div>"
    @pagination = $(".pagination_container")
    ListPagination.setup data

  delegateEvents: =>
    @searchInput.on "changed_after_input", @search

  search: =>
    do @loading
    $.ajax
      url: "/backend/users.json"
      data:
        search: @searchInput.val()
    .done (data)=>
      @setupPagination
        current_page: data.pagination.current_page
        per_page: data.pagination.per_page
        total_entries: data.pagination.total_entries
        callback: (page)=> window.location = "/backend/users?search=#{@searchInput.val()}&page=#{page}"
      @el.html $.tmpl("tmpl/line/user", data.entries)

  loading: =>
    @el.html "<div><span class='loading'><img src='/assets/loading.gif'/></span></div>"