class window.App.SearchOverviewController extends Spine.Controller

  elements:
    "#models": "models"
    "#software": "software"
    "#items": "items"
    "#licenses": "licenses"
    "#users": "users"
    "#delegations": "delegations"
    "#contracts": "contracts"
    "#orders": "orders"
    "#options": "options"
    "#loading": "loading"

  constructor: ->
    super
    @previewAmount = 5
    do @searchModels
    do @searchSoftware
    do @searchItems
    do @searchLicenses
    do @searchOptions
    do @searchUsers
    do @searchDelegations
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
        type: "model"
        per_page: @previewAmount
        search_term: @searchTerm
    .done (data, status, xhr)=> 
      models = (App.Model.find datum.id for datum in data)
      @fetchAvailability(models).done =>
        @render @models, "manage/views/models/line", models, xhr

  searchSoftware: =>
    App.Software.ajaxFetch
      data: $.param
        type: "software"
        per_page: @previewAmount
        search_term: @searchTerm
    .done (data, status, xhr)=>
      software = (App.Software.find datum.id for datum in data)
      @fetchAvailability(software).done =>
        @render @software, "manage/views/software/line", software, xhr

  render: (el, templatePath, records, xhr)=>
    totalCount = JSON.parse(xhr.getResponseHeader("X-Pagination")).total_count
    do @removeLoading
    if records.length
      el.find(".list-of-lines").html(
        App.Render(
          templatePath,
          records,
          currentInventoryPool: App.InventoryPool.current,
          accessRight: App.AccessRight,
          currentUserRole: App.User.current.role
        )
      )
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
        type: "item"
        per_page: @previewAmount
        search_term: @searchTerm
        current_inventory_pool: false
    .done (data, status, xhr)=> 
      items = (App.Item.find datum.id for datum in data)
      @fetchModels(items).done =>
        @fetchCurrentItemLocation(items).done =>
          @render @items, "manage/views/items/line", items, xhr

  searchLicenses: =>
    App.License.ajaxFetch
      data: $.param
        type: "license"
        per_page: @previewAmount
        search_term: @searchTerm
    .done (data, status, xhr)=>
      licenses = (App.License.find datum.id for datum in data)
      @fetchModels(licenses).done =>
        @fetchCurrentItemLocation(licenses).done =>
          @render @licenses, "manage/views/licenses/line", licenses, xhr

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
        current_inventory_pool: false

  searchDelegations: =>
    App.User.ajaxFetch
      data: $.param
        per_page: @previewAmount
        search_term: @searchTerm
        type: 'delegation'
    .done (data, status, xhr)=>
      delegations = (App.User.find datum.id for datum in data)
      App.User.fetchDelegators delegations, =>
        @render @delegations, "manage/views/users/search_result_line", delegations, xhr

  searchUsers: =>
    App.User.ajaxFetch
      data: $.param
        per_page: @previewAmount
        search_term: @searchTerm
        type: 'user'
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
      @fetchUsers(contracts, "all").done =>
        @fetchReservations(contracts).done =>
          @render @contracts, "manage/views/contracts/line", contracts, xhr

  fetchUsers: (records, all = false) =>
    ids = _.uniq _.map records, (r)-> r.user_id
    return {done: (c)->c()} unless ids.length
    data =
      ids: ids
      paginate: false
    $.extend data, {all: true} if all == "all"
    App.User.ajaxFetch
      data: $.param(data)
    .done (data)=>
      users = (App.User.find datum.id for datum in data)
      App.User.fetchDelegators users

  fetchReservations: (records)=>
    ids = _.flatten _.map records, (r)-> r.id
    return {done: (c)->c()} unless ids.length
    App.Reservation.ajaxFetch
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
        @fetchReservations(contracts).done =>
          @fetchPurposes(contracts).done =>
            @render @orders, "manage/views/contracts/line", contracts, xhr

  fetchPurposes: (contracts)=>
    ids = _.compact _.filter (_.map (_.flatten (_.map contracts, (o) -> o.reservations().all())), (l) -> l.purpose_id), (id) -> not App.Purpose.exists(id)?
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
