class window.App.ContractLineAssignOrCreateController extends Spine.Controller

  elements:
    "#assign-or-add-input": "input"
    "#add-start-date": "addStartDate"
    "#add-end-date": "addEndDate"

  events:
    "submit": "submit"

  constructor: ->
    super
    new App.ContractLinesAddController
      el: @el
      user: @user
      status: @status
      contract: @contract
      optionsEnabled: true

  getStartDate: => moment(@addStartDate.val(), i18n.date.L)

  getEndDate: => moment(@addEndDate.val(), i18n.date.L)

  submit: (e)=>
    e.preventDefault()
    e.stopImmediatePropagation()
    inventoryCode = @input.val()
    return false unless inventoryCode.length
    App.ContractLine.assignOrCreate
      start_date: @getStartDate().format("YYYY-MM-DD")
      end_date: @getEndDate().format("YYYY-MM-DD")
      code: inventoryCode
      contract_id: @contract.id
    .done((data) => @assignedOrCreated inventoryCode, data)
    .error (e)=>
      App.Flash
        type: "error"
        message: e.responseText
    @input.val("")

  assignedOrCreated: (inventoryCode, data)=>
    if App.ContractLine.exists(data.id) # assigned
      line = App.ContractLine.update data.id, data
      if line.model_id?
        App.Flash
          type: "success"
          message: _jed "%s assigned to %s", [inventoryCode, line.model().name()]
      else if line.option_id?
        App.Flash
          type: "notice"
          message: _jed("%s quantity increased to %s", [line.option().name(), line.quantity])
    else # created
      line = App.ContractLine.addRecord new App.ContractLine(data)
      done = =>
        App.Contract.trigger "refresh", @contract
        App.Flash
          type: "success"
          message: _jed("Added %s", line.model().name())
      if line.model_id?
        App.Item.ajaxFetch
          data: $.param
            ids: [line.item_id]
        .done =>
          App.Model.ajaxFetch
            data: $.param
              ids: [line.model_id]
          .done(done)
      else if line.option_id?
        App.Option.ajaxFetch
          data: $.param
            ids: [line.option_id]
        .done(done)
    App.LineSelectionController.add line.id