class window.App.ContractLinesChangeController extends window.App.BorrowBookingCalendarDialogController

  createContractLine: =>
    contract_line = new App.ContractLine
      model_id: @modelId
      start_date: @getStartDate().format("YYYY-MM-DD")
      end_date: @getEndDate().format("YYYY-MM-DD")
      inventory_pool_id: @getSelectedInventoryPool().id
      quantity: 1
    App.ContractLine.ajaxChange(contract_line, "create", {})

  # overwrite
  done: (data)=>
    for contract in App.Contract.currents
      App.Contract.trigger "refresh", contract
    super

  # overwrite
  getAvailability: (inventoryPool)=> @availabilities[inventoryPool.id].withoutLines(@lines)

  # overwrite
  store: =>
    difference = @getQuantity() - @quantity
    if difference < 0  # destroy lines in the amount of the quantity difference
      linesToBeDestroyed = @lines[0..(Math.abs(difference)-1)]
      deletionDone = _.after linesToBeDestroyed.length, @changeRange
      for line in linesToBeDestroyed
        do (line)->
          App.ContractLine.ajaxChange(line, "destroy", {}).done =>
            line.remove()
            do deletionDone
      @lines = _.reject @lines, (l)-> _.include(linesToBeDestroyed, l)
    else if difference > 0 # create new lines in the amount of the quantity difference
      finish = _.after difference, @changeRange
      for time in [1..difference]
        @createContractLine()
        .done (datum) =>
          @lines.push App.ContractLine.find datum.id
          do finish
    else # no quantity difference, try to change the range
      do @changeRange

  changeRange: => 
    if @getStartDate().format("YYYY-MM-DD") != @startDate or @getEndDate().format("YYYY-MM-DD") != @endDate
      ajax = App.ContractLine.changeTimeRange @lines, @getStartDate(), @getEndDate(), @getSelectedInventoryPool()
      ajax.done @done
      ajax.fail @fail
    else
      do @done
