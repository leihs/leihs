class window.App.ReservationAssignOrCreateController extends Spine.Controller

  elements:
    "#add-start-date": "addStartDate"
    "#add-end-date": "addEndDate"

  constructor: ->
    super
    that = @

    reservationsAddController = new App.ReservationsAddController
      el: @el
      user: @user
      status: @status
      contract: @contract
      optionsEnabled: true
      modelsPerPage: 30
      optionsPerPage: 100
      onSubmitInventoryCode: @submit
      addModelForHandOver: true

    onChangeCallback = (value) ->
      that.inputValue = value
      that.autocompleteController.setProps(isLoading: true)
      reservationsAddController.search value, (data)->
        that.autocompleteController.setProps(searchResults: data, isLoading: false)

    # create and mount the input field:
    props =
      onChange: _.debounce(onChangeCallback, 300)
      onSelect: reservationsAddController.select
      isLoading: false
      placeholder: _jed("Inventory code, model name, search term")

    @autocompleteController =
      new App.HandOverAutocompleteController \
        props,
        @el.find("#assign-or-add-input")[0]

    @autocompleteController._render()

    window.autocompleteController = @autocompleteController

    reservationsAddController.setupAutocomplete(@autocompleteController)

  getStartDate: => moment(@addStartDate.val(), i18n.date.L)

  getEndDate: => moment(@addEndDate.val(), i18n.date.L)

  submit: (inventoryCode)=>
    # debugger
    console.log 'TEST', inventoryCode
    return false unless inventoryCode?.length
    App.Reservation.assignOrCreate
      start_date: @getStartDate().format("YYYY-MM-DD")
      end_date: @getEndDate().format("YYYY-MM-DD")
      code: inventoryCode
      contract_id: @contract.id
    .done((data) =>
      console.log data
      @assignedOrCreated inventoryCode, data)
    .error (e)=>
      App.Flash
        type: "error"
        message: e.responseText
    @autocompleteController.getInstance().resetInput()

  assignedOrCreated: (inventoryCode, data)=>
    console.log 'assignedOrCreated', {inventoryCode, data}, App.Reservation.exists(data.id)
    # debugger
    done = =>
      if App.Reservation.exists(data.id) # assigned
        line = App.Reservation.update data.id, data
        if line.model_id?
          App.Flash
            type: "success"
            message: _jed "%s assigned to %s", [inventoryCode, line.model().name()]
        else if line.option_id?
          App.Flash
            type: "notice"
            message: _jed("%s quantity increased to %s", [line.option().name(), line.quantity])
      else # created
        line = App.Reservation.addRecord new App.Reservation(data)
        App.Contract.trigger "refresh", @contract
        App.Flash
          type: "success"
          message: _jed("Added %s", line.model().name())
      App.LineSelectionController.add line.id

    if data.model_id?
      App.Item.ajaxFetch
        data: $.param
          ids: [data.item_id]
      .done =>
        App.Model.ajaxFetch
          data: $.param
            ids: [data.model_id]
        .done(done)
    else if data.option_id?
      App.Option.ajaxFetch
        data: $.param
          ids: [data.option_id]
      .done(done)
