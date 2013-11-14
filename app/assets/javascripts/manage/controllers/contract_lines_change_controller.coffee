class window.App.ContractLinesChangeController extends window.App.ManageBookingCalendarDialogController

  createContractLine: =>
    contract_line = new App.ContractLine
      model_id: _.first(@models).id
      start_date: @getStartDate().format("YYYY-MM-DD")
      end_date: @getEndDate().format("YYYY-MM-DD")
      contract_id: @contract?.id
      purpose_id: _.first(@lines).purpose_id
      quantity: 1
    App.ContractLine.ajaxChange(contract_line, "create", {})

  # overwrite
  done: (data)=> 
    App.ContractLine.trigger "refresh", (App.ContractLine.find datum.id for datum in data)
    super

  # overwrite
  store: =>
    if @models.length == 1
      do @storeItemLine
    else if @models.length == 0
      do @storeOptionLine
    else
      do @changeRange
    
  storeItemLine: =>
    difference = @getQuantity() - @quantity
    if difference < 0  # destroy lines in the amount of the quantity difference
      linesToBeDestroyed = @lines[0..(Math.abs(difference)-1)]
      deletionDone = _.after linesToBeDestroyed.length, @changeRange
      @lines = _.reject @lines, (l)-> _.include(linesToBeDestroyed, l)
      for line in linesToBeDestroyed
        do (line)->
          App.ContractLine.ajaxChange(line, "destroy", {}).done => deletionDone
    else if difference > 0 # create new lines in the amount of the quantity difference
      finish = _.after difference, @changeRange
      for time in [1..difference]
        @createContractLine()
        .done (datum) =>
          @lines.push App.ContractLine.find datum.id
          do finish
    else # no quantity difference, try to change the range
      do @changeRange

  storeOptionLine: =>
    if @getQuantity()?
      line = _.first @lines
      line.updateAttributes 
        quantity: @getQuantity()
        start_date: @getStartDate().format("YYYY-MM-DD")
        end_date: @getEndDate().format("YYYY-MM-DD")
      @done line.contract()
    else 
      do @changeRange

  changeRange: => 
    if @getStartDate().format("YYYY-MM-DD") != @startDate or @getEndDate().format("YYYY-MM-DD") != @endDate
      App.ContractLine.changeTimeRange(@lines, (@getStartDate() unless @startDateDisabled), @getEndDate())
      .done(@done)
      .fail @fail
    else
      do @done