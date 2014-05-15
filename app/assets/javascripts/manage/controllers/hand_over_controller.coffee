class window.App.HandOverController extends Spine.Controller

  elements:
    "#status": "status"
    "#lines": "linesContainer"

  events:
    "click [data-hand-over-selection]": "handOver"
    "click #swap-user": "swapUser"

  constructor: ->
    super
    @lineSelection = new App.LineSelectionController {el: @el, markVisitLinesController: new App.MarkVisitLinesController {el: @el}}
    @fetchFunctionsSetup
      "Model": "Item"
      "Software": "License"
    do @initalFetch
    new App.ContractLinesDestroyController {el: @el}
    new App.ContractLineAssignItemController {el: @el}
    new App.TimeLineController {el: @el}
    new App.ContractLineAssignOrCreateController {el: @el.find("#assign-or-add"), user: @user, contract: @contract}
    new App.ContractLinesEditController {el: @el, user: @user, contract: @contract}
    new App.OptionLineChangeController {el: @el}

  delegateEvents: =>
    super
    App.ContractLine.on "change destroy", (data)=> if data.option_id? then @render(true) else do @fetchAvailability
    App.Contract.on "refresh", @fetchAvailability
    App.ContractLine.on "update", (data)=> 
      if @notFetchedItemIds().length
        @fetchItems().done =>
          if @notFetchedLicenseIds().length
            @fetchLicenses().done => @render(@initalAvailabilityFetched?)
      else
        @render(@initalAvailabilityFetched?)

  initalFetch: =>
    if @getLines().length
      if @notFetchedItemIds().length
        @fetchItems().done =>
          if @notFetchedLicenseIds().length
            @fetchLicenses().done => do @fetchAvailability
      else
        do @fetchAvailability 

  fetchAvailability: =>
    @render false
    ids = _.uniq(_.map(_.filter(@getLines(), (l)-> l.model_id?), (l)->l.model().id))
    if ids.length
      @status.html App.Render "manage/views/availabilities/loading"
      App.Availability.ajaxFetch
        data: $.param
          model_ids: ids
          user_id: @user.id
      .done (data)=>
        @initalAvailabilityFetched = true
        @status.html App.Render "manage/views/availabilities/loaded"
        @render true
    else
      @status.html App.Render "manage/views/users/hand_over/no_handover_found"

  getLines: => _.flatten _.map(@user.contracts().all(), (c)->c.lines().all())

  fetchFunctionsSetup: (classTypePairs) =>
    # macro for providing functions like 'notFetchedItemIds' and 'fetchItems'

    filterHelper = (modelClass, itemClass) =>
      _.filter _.compact(_.map(@getLines(), (l) -> if l.model().constructor.name == modelClass then l.item_id else null)), (id) -> not App[itemClass].exists(id)?

    fetchHelper = (className, ids) =>
      App[className].ajaxFetch
        data: $.param
          ids: ids
          paginate: 'false'

    _.each classTypePairs, (itemClassName, modelClassName) =>
      filterFunctionName = "notFetched" + itemClassName + "Ids"
      this[filterFunctionName] = => filterHelper modelClassName, itemClassName
      this["fetch" + itemClassName + "s"] = => fetchHelper itemClassName, do this[filterFunctionName]

  render: (renderAvailability)=> 
    @linesContainer.html App.Render "manage/views/lines/grouped_lines_with_action_date", App.Modules.HasLines.groupByDateRange(@getLines(), false, "start_date"), 
      linePartial: "manage/views/lines/hand_over_line"
      renderAvailability: renderAvailability
    do @lineSelection.restore

  handOver: => new App.HandOverDialogController
    user: @user
    contract: @contract

  swapUser: =>
    lines = (App.ContractLine.find id for id in App.LineSelectionController.selected)
    new App.SwapUsersController
      lines: lines
