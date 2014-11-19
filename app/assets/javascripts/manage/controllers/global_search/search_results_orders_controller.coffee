#= require ./search_results_controller
class window.App.SearchResultsOrdersController extends App.SearchResultsController

  model: "Contract"
  templatePath: "manage/views/contracts/line"

  constructor: ->
    super
    new App.LinesCellTooltipController {el: @el}
    new App.UserCellTooltipController {el: @el}
    new App.ContractsApproveController {el: @el}
    new App.ContractsRejectController {el: @el, async: true, callback: @orderRejected}

  fetch: (page, target, callback)=>
    @fetchOrders(page).done (data)=>
      orders = (App.Contract.find datum.id for datum in data)
      @fetchUsers(orders).done =>
        @fetchContractLines(orders).done =>
          @fetchPurposes(orders).done =>
            do callback

  fetchOrders: (page)=>
    App.Contract.ajaxFetch
      data: $.param
        page: page
        search_term: @searchTerm
        status: ["approved", "submitted", "rejected"]

  fetchUsers: (orders)=>
    ids = _.uniq _.map orders, (r)-> r.user_id
    return {done: (c)->c()} unless ids.length
    App.User.ajaxFetch
      data: $.param
        ids: ids
        paginate: false
    .done (data)=>
      users = (App.User.find datum.id for datum in data)
      App.User.fetchDelegators users

  fetchContractLines: (orders)=>
    ids = _.flatten _.map orders, (r)-> r.id
    return {done: (c)->c()} unless ids.length
    App.ContractLine.ajaxFetch
      data: $.param
        contract_ids: ids

  fetchPurposes: (orders)=>
    ids = _.compact _.filter (_.map (_.flatten (_.map orders, (o) -> o.lines().all())), (l) -> l.purpose_id), (id) -> not App.Purpose.exists(id)?
    return {done: (c)=>c()} unless ids.length
    App.Purpose.ajaxFetch
      data: $.param
        purpose_ids: ids
        paginate: false
