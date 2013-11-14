class window.App.VisitsIndexController extends Spine.Controller

  elements:
    "#visits": "list"

  constructor: ->
    super
    new App.LinesCellTooltipController {el: @el}
    new App.UserCellTooltipController {el: @el}
    new App.LatestReminderTooltipController {el: @el}
    new App.HandOversDeleteController {el: @el}
    new App.TakeBacksSendReminderController {el: @el}
    @pagination = new App.ListPaginationController {el: @list, fetch: @fetch}
    @search = new App.ListSearchController {el: @el.find("#list-search"), reset: @reset}
    @range = new App.ListRangeController {el: @el.find("#list-range"), reset: @reset}
    @tabs = new App.ListTabsController {el: @el.find("#list-tabs"), reset: @reset, data:{actions: ["hand_over", "take_back"]}}
    do @reset

  reset: =>
    @visits = {}
    @list.html App.Render "manage/views/lists/loading"
    @fetch 1, @list

  fetch: (page, target)=>
    @fetchVisits(page).done =>
      @fetchContractLines(page).done =>
        @fetchUsers(page).done =>
          @fetchPurposes(page).done => 
            @render target, @visits[page], page

  fetchVisits: (page)=>
    App.Visit.ajaxFetch
      data: $.param $.extend @tabs.getData(),
        search_term: @search.term()
        page: page
        range: @range.get()
    .done (data, status, xhr) => 
      @pagination.set JSON.parse(xhr.getResponseHeader("X-Pagination"))
      visits = (App.Visit.find(datum.id) for datum in data)
      @visits[page] = visits

  fetchContractLines: (page)=>
    ids = _.flatten _.map @visits[page], (v)-> v.contract_line_ids
    return {done: (c)=>c()} unless ids.length
    App.ContractLine.ajaxFetch
      data: $.param
        ids: ids

  fetchUsers: (page)=>
    ids = _.filter (_.map @visits[page], (c) -> c.user_id), (id) -> not App.User.exists(id)?
    return {done: (c)=>c()} unless ids.length
    App.User.ajaxFetch
      data: $.param
        ids: ids

  fetchPurposes: (page)=>
    ids = _.compact _.filter (_.map (_.flatten (_.map @visits[page], (o) -> o.lines().all())), (l) -> l.purpose_id), (id) -> not App.Purpose.exists(id)?
    return {done: (c)=>c()} unless ids.length
    App.Purpose.ajaxFetch
      data: $.param
        purpose_ids: ids

  render: (target, data, page)=> 
    target.html App.Render "manage/views/visits/line", data
    @pagination.renderPlaceholders() if page == 1