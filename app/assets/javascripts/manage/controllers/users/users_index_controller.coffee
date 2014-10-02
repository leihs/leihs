class window.App.UsersIndexController extends Spine.Controller

  elements:
    "#user-list": "list"

  constructor: (options) ->
    super
    @users = {}
    new App.UserCellTooltipController {el: @list}
    @pagination = new App.ListPaginationController {el: @list, fetch: @fetch}
    @search = new App.ListSearchController {el: @el.find("#list-search"), reset: @reset}
    @filter = new App.ListFiltersController {el: @el.find("#list-filters"), reset: @reset}
    do @reset

  reset: =>
    @users = {}
    @list.html App.Render "manage/views/lists/loading"
    @fetch 1, @list

  fetch: (page, target) =>
    @fetchUsers(page).done =>
      @fetchAccessRights(page).done =>
        @render target, @users[page], page

  fetchUsers: (page) =>
    App.User.ajaxFetch
      data: $.param $.extend @filter.getData(),
        page: page
        search_term: @search.term()
        role: @role
        all: true if _.isEmpty @role
    .done (data, status, xhr) =>
      @pagination.set JSON.parse(xhr.getResponseHeader("X-Pagination"))
      users = (App.User.find(datum.id) for datum in data)
      @users[page] = users
      App.User.fetchDelegators users


  fetchAccessRights: (page) =>
    ids = _.map @users[page], (u) -> u.id
    if ids.length
      App.AccessRight.ajaxFetch
        data: $.param
          user_ids: ids
    else
      {done: (c) -> c()}

  render: (target, data, page) =>
    target.html App.Render "manage/views/users/line", data, currentInventoryPool: App.InventoryPool.current
    @pagination.renderPlaceholders() if page == 1
