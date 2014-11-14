class window.App.ContractLinesAddController extends Spine.Controller

  elements:
    "#add-start-date": "addStartDate"
    "#add-end-date": "addEndDate"
    "[data-add-contract-line]": "input"

  events:
    "focus [data-add-contract-line]": "setupAutocomplete"
    "click [type='submit']": "showExplorativeSearch"
    "submit": "submit"

  constructor: ->
    super 
    @preventSubmit = false
    do @setupDatepickers
    @input.preChange()

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

  searchModels: (callback)=>
    App.Model.ajaxFetch
      data: $.param
        search_term: @input.val()
        used: true
        as_responsible_only: true
        per_page: 5
    .done (data)=> 
      @models = (App.Model.find(datum.id) for datum in data)
      @fetchAvailabilities => do callback

  searchOptions: (callback)=>
    App.Option.ajaxFetch
      data: $.param
        search_term: @input.val()
        per_page: 5
    .done (data)=> 
      @options = (App.Option.find(datum.id) for datum in data)
      do callback

  searchTemplates: (callback)=>
    App.Template.ajaxFetch
      data: $.param
        search_term: @input.val()
        per_page: 5
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

  setupAutocomplete: (data)->
    @input.autocomplete
      appendTo: @el
      source: (request, response)=> 
        response []
        @search request, response
      search: => console.log "Search"
      focus: => return false
      select: @select
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "manage/views/lines/add/autocomplete_element", item).data("value", item).appendTo(ul)
    @input.autocomplete("search")

  search: (request, response)=>
    return false unless @input.val().length
    @models = @options = @templates = @availabilities = @options = null
    done = =>
      if @models? and @templates? and @availabilities? and (if @optionsEnabled then @options? else true)
        data = []
        @pushModelsTo data
        @pushOptionsTo data if @optionsEnabled
        @pushTemplatesTo data
        response data if @input.is(":focus")
    @searchModels done
    @searchTemplates done
    @searchOptions(done) if @optionsEnabled

  select: (e, ui)=>
    e.preventDefault()
    record = ui.item.record
    @add record, @getStartDate(), @getEndDate()
    @preventSubmit = true
    setTimeout (=> 
      @preventSubmit = false
      @input.val("").change()
    ), 100

  submit: (e)=>
    e.preventDefault() if e?
    return false if @preventSubmit
    inventoryCode = @input.val()
    if inventoryCode.length
      console.log inventoryCode
      App.Inventory.findByInventoryCode(inventoryCode).done @addInventoryItem, inventoryCode
    @input.val("").change()

  addInventoryItem: (data, inventoryCode)=>
    console.log inventoryCode
    if data?
      if data.model_id?
        App.Model.ajaxFetch({id: data.model_id}).done (data)=> @add App.Model.find(data.id), @getStartDate(), @getEndDate()
    else
      App.Flash
        type: "error"
        message: _jed "The Inventory Code %s was not found.", inventoryCode

  add: (record, startDate, endDate)=>
    if record instanceof App.Model
      @addModel record, startDate, endDate
    else if record instanceof App.Option
      @addOption record, startDate, endDate
    else if record instanceof App.Template
      @addTemplate record, startDate, endDate

  addModel: (model, startDate, endDate)=>
    App.ContractLine.createOne
      inventory_pool_id: App.InventoryPool.current.id
      start_date: moment(startDate).format "YYYY-MM-DD"
      end_date: moment(endDate).format "YYYY-MM-DD"
      contract_id: @contract.id
      purpose_id: @purpose?.id
      quantity: 1
      model_id: model.id
    .done (line)->
      App.LineSelectionController.add line.id
      App.Flash
        type: "notice"
        message: _jed("Added %s", model.name())
    .fail (e)->
      App.Flash
        type: "error"
        message: e.responseText


  addOption: (option, startDate, endDate)=>
    line = _.find @contract.lines().all(), (l)-> 
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
      App.ContractLine.create
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
    App.ContractLine.createForTemplate
      inventory_pool_id: App.InventoryPool.current.id
      start_date: moment(startDate).format "YYYY-MM-DD"
      end_date: moment(endDate).format "YYYY-MM-DD"
      contract_id: @contract.id
      purpose_id: @purpose?.id
      template_id: template.id
    .done (lines)=>
      App.LineSelectionController.add line.id for line in lines
      App.Flash
        type: "notice"
        message: _jed("Added %s", template.name)

  showExplorativeSearch: =>
    if @input.val().length == 0
      new App.ContractLinesExplorativeAddController
        contract: @contract
        startDate: @getStartDate()
        endDate: @getEndDate()
        addModel: @addModel
