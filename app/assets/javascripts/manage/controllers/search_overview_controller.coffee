class window.App.SearchOverviewController extends Spine.Controller

  elements:
    "#models": "models"
    "#items": "items"
    "#users": "users"
    "#contracts": "contracts"
    "#orders": "orders"
    "#options": "options"
    "#loading": "loading"

  constructor: ->
    super
    @previewAmount = 5
    do @searchModels
    do @searchItems
    do @searchOptions
    do @searchUsers
    do @searchContracts
    do @searchOrders
    new App.LatestReminderTooltipController {el: @el}
    new App.LinesCellTooltipController {el: @el}
    new App.UserCellTooltipController {el: @el}
    new App.HandOversDeleteController {el: @el}
    new App.ContractsApproveController {el: @el}
    new App.TakeBacksSendReminderController {el: @el}
    new App.ContractsRejectController {el: @el, async: true, callback: @orderRejected}
    new App.TimeLineController {el: @el}

  removeLoading: _.after 5, -> @loading.remove()

  searchModels: =>
    App.Model.ajaxFetch
      data: $.param
        per_page: @previewAmount
        search_term: @searchTerm
    .done (data, status, xhr)=> 
      models = (App.Model.find datum.id for datum in data)
      @fetchAvailability(models).done =>
        @render @models, "manage/views/models/line", models, xhr

  render: (el, templatePath, records, xhr)=>
    totalCount = JSON.parse(xhr.getResponseHeader("X-Pagination")).total_count
    do @removeLoading
    if records.length
      el.find(".list-of-lines").html App.Render templatePath, records
      el.removeClass("hidden")
    if totalCount > @previewAmount
      el.find("[data-type='show-all']").removeClass("hidden").append $("<span class='badge margin-left-s'>#{totalCount}</span>")

  fetchAvailability: (models)=>
    ids = _.map models, (m)-> m.id
    return {done: (c)->c()} unless ids.length
    App.Availability.ajaxFetch
      url: App.Availability.url()+"/in_stock"
      data: $.param
        model_ids: ids

  searchItems: =>
    App.Item.ajaxFetch
      data: $.param
        per_page: @previewAmount
        search_term: @searchTerm
    .done (data, status, xhr)=> 
      items = (App.Item.find datum.id for datum in data)
      @fetchModels(items).done =>
        @fetchCurrentItemLocation(items).done =>
          @render @items, "manage/views/items/line", items, xhr

  fetchModels:(items) =>
    ids = _.uniq _.map items, (m)-> m.model_id
    return {done: (c)->c()} unless ids.length
    App.Model.ajaxFetch
      data: $.param
        ids: ids
        paginate: false
        include_package_models: true

  fetchCurrentItemLocation: (items)=>
    ids = _.map items, (i)-> i.id
    return {done: (c)->c()} unless ids.length
    App.CurrentItemLocation.ajaxFetch
      data: $.param
        ids: ids
        all: true
        paginate: false

  searchUsers: =>
    App.User.ajaxFetch
      data: $.param
        per_page: @previewAmount
        search_term: @searchTerm
    .done (data, status, xhr)=>
      users = (App.User.find datum.id for datum in data)
      @render @users, "manage/views/users/search_result_line", users, xhr

  searchContracts: =>
    App.Contract.ajaxFetch
      data: $.param
        per_page: @previewAmount
        search_term: @searchTerm
        status: ["signed", "closed"]
    .done (data, status, xhr)=>
      contracts = (App.Contract.find datum.id for datum in data)
      @fetchUsers(contracts).done =>
        @fetchContractLines(contracts).done =>
          @render @contracts, "manage/views/contracts/line", contracts, xhr

  fetchUsers: (records)=>
    ids = _.uniq _.map records, (r)-> r.user_id
    return {done: (c)->c()} unless ids.length
    App.User.ajaxFetch
      data: $.param
        ids: ids
        paginate: false

  fetchContractLines: (records)=>
    ids = _.flatten _.map records, (r)-> r.id
    return {done: (c)->c()} unless ids.length
    App.ContractLine.ajaxFetch
      data: $.param
        contract_ids: ids
        paginate: false

  searchOrders: =>
    App.Contract.ajaxFetch
      data: $.param
        per_page: @previewAmount
        search_term: @searchTerm
        status: ["approved", "submitted", "rejected"]
    .done (data, status, xhr)=>
      contracts = (App.Contract.find datum.id for datum in data)
      @fetchUsers(contracts).done =>
        @fetchContractLines(contracts).done =>
          @fetchPurposes(contracts).done =>
            @render @orders, "manage/views/contracts/line", contracts, xhr

  fetchPurposes: (contracts)=>
    ids = _.compact _.filter (_.map (_.flatten (_.map contracts, (o) -> o.lines().all())), (l) -> l.purpose_id), (id) -> not App.Purpose.exists(id)?
    return {done: (c)=>c()} unless ids.length
    App.Purpose.ajaxFetch
      data: $.param
        purpose_ids: ids
        paginate: false

  searchOptions: =>
    App.Option.ajaxFetch
      data: $.param
        per_page: @previewAmount
        search_term: @searchTerm
    .done (data, status, xhr)=>
        options = (App.Option.find datum.id for datum in data)
        @render @options, "manage/views/options/line", options, xhr
