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
      fi = @fetchItems() if @notFetchedItemIds().length
      fl = @fetchLicenses() if @notFetchedLicenseIds().length
      if fi or fl
        $.when(fi, fl).done => @render(@initialAvailabilityFetched?)
      else
        @render(@initialAvailabilityFetched?)

  initalFetch: =>
    if @getLines().length
      fi = $.Deferred @fetchItems if @notFetchedItemIds().length
      fl = $.Deferred @fetchLicenses if @notFetchedLicenseIds().length
      if fi? or fl?
        $.when(fi, fl).done(@fetchAvailability)
      else
        @fetchAvailability()

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
        @initialAvailabilityFetched = true
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

  handOver: =>
    if @validate()
      new App.HandOverDialogController
        user: @user
        contract: @contract
    else
      App.Flash
        type: "error"
        message: _jed('End Date cannot be in the past')

  swapUser: =>
    lines = (App.ContractLine.find id for id in App.LineSelectionController.selected)
    new App.SwapUsersController
      lines: lines

  validate: =>
    lines = (App.ContractLine.find id for id in App.LineSelectionController.selected)
    _.all lines, (line)->
      # checking if end_date are in the past
      not moment(line.end_date).isBefore(moment().format("YYYY-MM-DD"))
