class window.App.ContractsIndexController extends Spine.Controller

  elements:
    "#contracts": "list"

  constructor: ->
    super
    new App.LinesCellTooltipController {el: @el}
    new App.UserCellTooltipController {el: @el}
    new App.ContractsApproveController {el: @el}
    new App.ContractsUnapproveController {el: @el}
    new App.ContractsRejectController {el: @el, async: true, callback: @orderRejected}
    @pagination = new App.ListPaginationController {el: @list, fetch: @fetch}
    @search = new App.ListSearchController {el: @el.find("#list-search"), reset: @reset}
    @filter = new App.ListFiltersController {el: @el.find("#list-filters"), reset: @reset}
    @range = new App.ListRangeController {el: @el.find("#list-range"), reset: @reset}
    @tabs = new App.ListTabsController {el: @el.find("#list-tabs"), reset: @reset, data:{status: @status}}
    do @reset

  reset: =>
    @contracts = {}
    @list.html App.Render "manage/views/lists/loading"
    @fetch 1, @list
    @pagination.page = 1

  fetch: (page, target)=>
    @fetchContracts(page).done =>
      @fetchUsers(page).done =>
        @fetchContractLines page, =>
          @fetchPurposes page, => 
            @render target, @contracts[page], page

  fetchContracts: (page)=>
    data = $.extend @tabs.getData(), $.extend @filter.getData(),
      search_term: @search.term()
      page: page
      range: @range.get()
    data = $.extend data, { from_verifiable_users: true } if App.User.current.role == "group_manager"
    App.Contract.ajaxFetch({ data: $.param data })
    .done (data, status, xhr) => 
      @pagination.set JSON.parse(xhr.getResponseHeader("X-Pagination"))
      contracts = (App.Contract.find(datum.id) for datum in data)
      @contracts[page] = contracts

  fetchContractLines: (page, callback)=>
    ids = _.map @contracts[page], (o) -> o.id
    do callback unless ids.length
    done = _.after Math.ceil(ids.length/300), callback
    _(ids).each_slice 300, (slice)=>
      App.ContractLine.ajaxFetch
        data: $.param
          contract_ids: slice
      .done done

  fetchUsers: (page)=>
    ids = _.filter (_.map @contracts[page], (c) -> c.user_id), (id) -> not App.User.exists(id)?
    return {done: (c)=>c()} unless ids.length
    App.User.ajaxFetch
      data: $.param
        ids: ids
        all: true

  fetchPurposes: (page, callback)=>
    ids = _.compact _.filter (_.map (_.flatten (_.map @contracts[page], (o) -> o.lines().all())), (l) -> l.purpose_id), (id) -> not App.Purpose.exists(id)?

    do callback unless ids.length
    done = _.after Math.ceil(ids.length/300), callback
    _(ids).each_slice 300, (slice)=>
      App.Purpose.ajaxFetch
        data: $.param
          purpose_ids: slice
      .done done

  render: (target, data, page)=> 
    target.html App.Render "manage/views/contracts/line", data, { accessRight: App.AccessRight, currentUserRole: App.User.current.role }
    @pagination.renderPlaceholders() if page == 1
