#= require ./search_results_controller
class window.App.SearchResultsContractsController extends App.SearchResultsController

  model: "Contract"
  templatePath: "manage/views/contracts/line"

  constructor: ->
    super
    new App.LinesCellTooltipController {el: @el}
    new App.UserCellTooltipController {el: @el}
    new App.TakeBacksSendReminderController {el: @el}

  fetch: (page, target, callback)=>
    @fetchContracts(page).done (data)=>
      contracts = (App.Contract.find datum.id for datum in data)
      @fetchUsers(contracts).done =>
        @fetchContractLines(contracts).done => do callback

  fetchContracts: (page)=>
    App.Contract.ajaxFetch
      data: $.param
        search_term: @searchTerm
        page: page
        status: ["signed", "closed"]

  fetchUsers: (contracts)=>
    ids = _.uniq _.map contracts, (r)-> r.user_id
    return {done: (c)->c()} unless ids.length
    App.User.ajaxFetch
      data: $.param
        ids: ids
        paginate: false
    .done (data)=>
      users = (App.User.find datum.id for datum in data)
      App.User.fetchDelegators users

  fetchContractLines: (contracts)=>
    ids = _.flatten _.map contracts, (r)-> r.id
    return {done: (c)->c()} unless ids.length
    App.ContractLine.ajaxFetch
      data: $.param
        contract_ids: ids
