class window.App.ReservationsAddController extends Spine.Controller

  elements:
    "#add-start-date": "addStartDate"
    "#add-end-date": "addEndDate"

  events:
    "click [type='submit']": "handleEvents"
    "submit": "handleEvents"

  handleEvents: (e) =>
    e?.preventDefault()
    focused = document.querySelector(':focus')
    value = @getInputValue()
    if value.length == 0
      if not focused or focused.nodeName == 'BUTTON'
        @showExplorativeSearch(e)
      else if focused.nodeName == 'INPUT'
        @submit(e)
    else
      @submit(e)

  constructor: (@onSubmitInventoryCode) ->
    super
    @preventSubmit = false
    do @setupDatepickers

  setupAutocomplete: (autocompleteController) =>
    @autocompleteController = autocompleteController

  search: (value, response)=>
    return false unless value.length
    @models = @options = @templates = @availabilities = @options = null
    handleResponses = =>
      if @models? and @templates? and @availabilities? and (if @optionsEnabled then @options? else true)
        data = []
        @pushModelsTo data
        @pushOptionsTo data if @optionsEnabled
        @pushTemplatesTo data
        response data # TODO: if @input.is(":focus")
    @searchModels(value, handleResponses)
    @searchTemplates(value, handleResponses)
    @searchOptions(value, handleResponses) if @optionsEnabled

  select: (item) =>
    @add item.record, @getStartDate(), @getEndDate()
    @autocompleteController._render()

  setupDatepickers: =>
    for date in [@addStartDate, @addEndDate]
      $(date).datepicker()
    @addStartDate.datepicker "option", "minDate", moment().startOf("day").toDate()
    @addEndDate.datepicker "option", "minDate", getTime: => moment(@addStartDate.val(), i18n.date.L).startOf("day").toDate()
    @addStartDate.datepicker "option", "onSelect", (newStartDate)=>
      newStartDate = moment(newStartDate, i18n.date.L).startOf("day")
      endDate = moment(@addEndDate.val(), i18n.date.L).startOf("day")
      if newStartDate.toDate() > endDate.toDate()
        @addEndDate.val newStartDate.format(i18n.date.L)

  getStartDate: => moment(@addStartDate.val(), i18n.date.L)

  getEndDate: => moment(@addEndDate.val(), i18n.date.L)

  pushModelsTo: (data)=>
    for model in @models
      if model.availability()?
        maxAvailableForUser = model.availability().maxAvailableForGroups(@getStartDate(), @getEndDate(), @user.groupIds)
        maxAvailableInTotal = model.availability().maxAvailableInTotal(@getStartDate(), @getEndDate())
        data.push
          name: model.name()
          availability: "#{maxAvailableForUser}(#{maxAvailableInTotal})/#{model.availability().total_rentable}"
          available: maxAvailableForUser > 0
          type: _jed "Model"
          record: model

  pushTemplatesTo: (data)=>
    for template in @templates
      data.push
        name: template.name
        available: true
        type: _jed "Template"
        record: template

  pushOptionsTo: (data)=>
    for option in @options
      data.push
        name: option.name()
        available: true
        type: _jed "Option"
        record: option

  searchModels: (value, callback)=>
    App.Model.ajaxFetch
      data: $.param
        search_term: value
        used: true
        as_responsible_only: true
        per_page: @modelsPerPage or 5
    .done (data)=>
      @models = (App.Model.find(datum.id) for datum in data)
      @fetchAvailabilities => do callback

  searchOptions: (value, callback)=>
    App.Option.ajaxFetch
      data: $.param
        search_term: value
        per_page: @optionsPerPage or 5
    .done (data)=>
      @options = (App.Option.find(datum.id) for datum in data)
      do callback

  searchTemplates: (value, callback)=>
    App.Template.ajaxFetch
      data: $.param
        search_term: value
        per_page: @templatesPerPage or 5
    .done (data)=>
      @templates = (App.Template.find(datum.id) for datum in data)
      do callback

  fetchAvailabilities: (callback)=>
    if @models? and @models.length
      App.Availability.ajaxFetch
        data: $.param
          model_ids: _.map @models, (m)-> m.id
          user_id: @user.id
      .done (data)=>
        @availabilities = (App.Availability.find(datum.id) for datum in data)
        do callback
    else
      @availabilities = []
      do callback

  getInputValue: => @autocompleteController.getInstance().state.value

  submit: (e)=>
    return false if @preventSubmit
    inventoryCode = @getInputValue()
    if inventoryCode.length
      App.Inventory.findByInventoryCode(inventoryCode).done((data) => @addInventoryItem(data, inventoryCode))
    @autocompleteController.getInstance().resetInput()

  addInventoryItem: (data, inventoryCode)=>
    if data?
      unless data.error?
        if data.model_id?
          App.Model.ajaxFetch({id: data.model_id}).done (data)=>
            @add App.Model.find(data.id), @getStartDate(), @getEndDate(), inventoryCode
        else
          option = App.Option.addRecord new App.Option(data)
          @add option, @getStartDate(), @getEndDate()
      else
        App.Flash
          type: "error"
          message: data.error
    else
      App.Flash
        type: "error"
        message: _jed "The Inventory Code %s was not found.", inventoryCode

  add: (record, startDate, endDate, inventoryCode)=>
    if record instanceof App.Model
      @addModel record, startDate, endDate, inventoryCode
    else if record instanceof App.Option
      @addOption record, startDate, endDate
    else if record instanceof App.Template
      @addTemplate record, startDate, endDate

  addModel: (model, startDate, endDate, inventoryCode)=>
    if @addModelForHandOver and inventoryCode
      # just continue in callback from ReservationAssignOrCreateController
      @onSubmitInventoryCode?(inventoryCode)
    else
      App.Reservation.createOne
        inventory_pool_id: App.InventoryPool.current.id
        start_date: moment(startDate).format "YYYY-MM-DD"
        end_date: moment(endDate).format "YYYY-MM-DD"
        contract_id: @contract.id
        purpose_id: @purpose?.id
        quantity: 1
        model_id: model.id
      .done (line)=>
        App.LineSelectionController.add line.id
        # always trigger this:
        @onSubmitInventoryCode?(inventoryCode)
        App.Flash
          type: "notice"
          message: _jed("Added %s", model.name())
      .fail (e)->
        App.Flash
          type: "error"
          message: e.responseText


  addOption: (option, startDate, endDate)=>
    line = _.find @contract.reservations().all(), (l)->
      l.option_id == option.id and
      moment(l.start_date).diff(startDate, "days") == 0 and
      moment(l.end_date).diff(endDate, "days") == 0
    if line
      quantity = line.quantity + 1
      line.updateAttributes
        quantity: quantity
      App.Flash
        type: "notice"
        message: _jed("%s quantity increased to %s", [option.name(), quantity])
      App.LineSelectionController.add line.id
    else
      App.Reservation.create
        inventory_pool_id: App.InventoryPool.current.id
        start_date: moment(startDate).format "YYYY-MM-DD"
        end_date: moment(endDate).format "YYYY-MM-DD"
        contract_id: @contract.id
        purpose_id: @purpose?.id
        quantity: 1
        option_id: option.id
      ,
        done: ->
          App.LineSelectionController.add @id
          App.Flash
            type: "notice"
            message: _jed("Added %s", option.name())

  addTemplate: (template, startDate, endDate)=>
    App.Reservation.createForTemplate
      inventory_pool_id: App.InventoryPool.current.id
      start_date: moment(startDate).format "YYYY-MM-DD"
      end_date: moment(endDate).format "YYYY-MM-DD"
      contract_id: @contract.id
      purpose_id: @purpose?.id
      template_id: template.id
    .done (reservations)=>
      App.LineSelectionController.add line.id for line in reservations
      App.Flash
        type: "notice"
        message: _jed("Added %s", template.name)

  showExplorativeSearch: (e) =>
    new App.ReservationsExplorativeAddController
      contract: @contract
      startDate: @getStartDate()
      endDate: @getEndDate()
      addModel: @addModel
