class window.App.TakeBackController extends Spine.Controller

  elements:
    "#status": "status"
    "#lines": "linesContainer"
    "form#assign": "form"
    "#assign-input": "input"

  events:
    "click [data-take-back-selection]": "takeBack"
    "click [data-inspect-item]": "inspectItem"
    "submit form#assign": "assign"
    "focus #assign-input": "showAutocomplete"
    "change [data-quantity-returned]": "changeQuantity"
    "preChange [data-quantity-returned]": "changeQuantity"

  constructor: ->
    super
    App.TakeBackController.readyForTakeBack = []
    @lineSelection = new App.LineSelectionController {el: @el, markVisitLinesController: new App.MarkVisitLinesController {el: @el}}
    if @getLines().length
      do @fetchAvailability
    do @setupAutocomplete
    new App.TimeLineController {el: @el}
    new App.ContractLinesEditController {el: @el, user: @user, contract: @contract, startDateDisabled: true, quantityDisabled: true}
    new PreChange "[data-quantity-returned]"

  delegateEvents: =>
    super
    App.ContractLine.on "refresh", @fetchAvailability
    App.Item.on "refresh", => @render(true)

  fetchAvailability: =>
    @render false
    ids = _.uniq(_.map(_.filter(@getLines(), (l)-> l.model_id?), (l)->l.model().id))
    done = (data)=>
      @initalAvailabilityFetched = true
      @status.html App.Render "manage/views/availabilities/loaded"
      @render true
    if ids.length
      @status.html App.Render "manage/views/availabilities/loading"
      App.Availability.ajaxFetch
        data: $.param
          model_ids: ids
          user_id: @user.id
      .done done
    else
      do done

  getLines: => _.flatten _.map(@user.contracts().all(), (c)->c.lines().all())

  render: (renderAvailability)=> 
    @linesContainer.html App.Render "manage/views/lines/grouped_lines_with_action_date", App.Modules.HasLines.groupByDateRange(@getLines(), false, "end_date"), 
      linePartial: "manage/views/lines/take_back_line"
      renderAvailability: renderAvailability
    do @lineSelection.restore

  takeBack: => 
    returnedQuantity = {}
    lines = (App.ContractLine.find id for id in App.LineSelectionController.selected)
    for line in lines
      if line.option_id?
        quantity = @getQuantity(line)
        if quantity == 0
          App.Flash
            type: "error"
            message: _jed "You have to provide the quantity for the things you want to return"
          return false
        else
          returnedQuantity[line.id] = @getQuantity(line)
    new App.TakeBackDialogController {user: @user, lines: lines, returnedQuantity: returnedQuantity}

  assign: (e)=>
    e.preventDefault() if e?
    inventoryCode = @input.val()
    line = _.find @getLines(), @getCheckLineFunction(inventoryCode)
    if line
      App.Flash
        type: "success"
        message: _jed "%s selected for take back", line.model().name()
      App.LineSelectionController.add line.id
      @increaseOption line if line.option_id
    # line for assignment not found because it was already assigned maximum possible before
    else if App.ContractLine.findByAttribute("option_id", App.Option.findByAttribute("inventory_code", inventoryCode)?.id)
      App.Flash
        type: "error"
        message: _jed "You can not take back more options then you handed over"
    else
      App.Flash
        type: "error"
        message: _jed "%s was not found for this take back", inventoryCode
    @input.val("").blur()

  getCheckLineFunction: (inv_code) =>
    el = @el
    (line) ->
      line.inventoryCode() == inv_code and
        (if line.option() then el.find(".line[data-id='#{line.id}'] input[data-quantity-returned]").val() < line.quantity else true)

  getQuantity: (line)=>
    input = @el.find(".line[data-id='#{line.id}'] input[data-quantity-returned]")
    quantity = unless input.val().length then 0 else parseInt(input.val())
    quantity = 1 if _.isNaN(quantity)
    return quantity

  increaseOption: (line)=>
    quantity = @getQuantity(line)+1
    input = @el.find(".line[data-id='#{line.id}'] input[data-quantity-returned]")
    input.val quantity
    App.Flash
      type: "success"
      message: _jed "%s quantity increased to %s", [line.model().name(), quantity]
    @changeQuantity {currentTarget: input}

  setupAutocomplete: =>
    @input.autocomplete
      appendTo: @el
      source: (request, response)=> 
        data = for line in @getLines()
          name: line.model().name()
          inventoryCode: line.inventoryCode()
          record: line
        regexp = RegExp(request.term, "i")
        data = _.filter data, (d)-> d.name.match(regexp) or d.inventoryCode?.match(regexp)
        response data
      focus: => return false
      select: @select
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "manage/views/lines/assign/autocomplete_element", item).data("value", item).appendTo(ul)

  select: (e, ui)=>
    @input.val ui.item.record.inventoryCode()
    do @assign

  showAutocomplete: => @input.autocomplete("search")

  changeQuantity: (e)=>
    target = $ e.currentTarget
    line = App.ContractLine.find target.closest("[data-id]").data "id"
    App.LineSelectionController.add(line.id)
    @lineSelection.markVisitLinesController?.update App.LineSelectionController.selected
    quantity = parseInt target.val()
    target.val(0) if _.isNaN(quantity)
    target.val(0) if quantity < 0
    if line.quantity < quantity
      App.Flash
        type: "error"
        message: _jed "You can not take back more items then you handed over"
      target.val line.quantity
      @lineSelection.markVisitLinesController?.update App.LineSelectionController.selected

  inspectItem: (e)=>
    item = App.Item.find $(e.currentTarget).data("item-id")
    new App.ItemInspectDialogController
      item: item
