class window.App.ContractsIndexController extends Spine.Controller

  elements:
    "#contracts": "list"

  constructor: ->
    super
    new App.LinesCellTooltipController {el: @el}
    new App.UserCellTooltipController {el: @el}
    new App.ContractsApproveController {el: @el}
    new App.ContractsRejectController {el: @el, async: true, callback: @orderRejected}
    @pagination = new App.ListPaginationController {el: @list, fetch: @fetch}
    @search = new App.ListSearchController {el: @el.find("#list-search"), reset: @reset}
    @range = new App.ListRangeController {el: @el.find("#list-range"), reset: @reset}
    @tabs = new App.ListTabsController {el: @el.find("#list-tabs"), reset: @reset, data:{status: @status}}
    do @reset

  reset: =>
    @contracts = {}
    @list.html App.Render "manage/views/lists/loading"
    @fetch 1, @list

  fetch: (page, target)=>
    @fetchContracts(page).done =>
      @fetchUsers(page).done =>
        @fetchContractLines(page).done =>
          @fetchPurposes(page).done => 
            @render target, @contracts[page], page

  fetchContracts: (page)=>
    App.Contract.ajaxFetch
      data: $.param $.extend @tabs.getData(),
        search_term: @search.term()
        page: page
        range: @range.get()
    .done (data, status, xhr) => 
      @pagination.set JSON.parse(xhr.getResponseHeader("X-Pagination"))
      contracts = (App.Contract.find(datum.id) for datum in data)
      @contracts[page] = contracts

  fetchContractLines: (page)=>
    ids = _.map @contracts[page], (o) -> o.id
    return {done: (c)=>c()} unless ids.length
    App.ContractLine.ajaxFetch
      data: $.param
        contract_ids: ids
          

  fetchUsers: (page)=>
    ids = _.filter (_.map @contracts[page], (c) -> c.user_id), (id) -> not App.User.exists(id)?
    return {done: (c)=>c()} unless ids.length
    App.User.ajaxFetch
      data: $.param
        ids: ids
        all: true

  fetchPurposes: (page)=>
    ids = _.compact _.filter (_.map (_.flatten (_.map @contracts[page], (o) -> o.lines().all())), (l) -> l.purpose_id), (id) -> not App.Purpose.exists(id)?
    return {done: (c)=>c()} unless ids.length
    App.Purpose.ajaxFetch
      data: $.param
        purpose_ids: ids

  render: (target, data, page)=> 
    target.html App.Render "manage/views/contracts/line", data
    @pagination.renderPlaceholders() if page == 1