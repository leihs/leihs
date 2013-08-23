class window.App.Borrow.OrderLinesChangeController extends window.App.Borrow.BookingCalendarDialog

  createOrderLine: (quantity)=>
    order_line = new App.OrderLine
      model_id: @modelId
      start_date: @getStartDate().format("YYYY-MM-DD")
      end_date: @getEndDate().format("YYYY-MM-DD")
      inventory_pool_id: @getSelectedInventoryPool().id
      quantity: quantity
    App.OrderLine.ajaxChange(order_line, "create", {})

  # overwrite
  done: (data)=>
    if @lines?
      line["available?"] = true for line in @lines
    App.Order.trigger "refresh", App.Order.current
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
          App.OrderLine.ajaxChange(line, "destroy", {}).done =>
            delete App.OrderLine.records[line.id]
            do deletionDone
      @lines = _.reject @lines, (l)-> _.include(linesToBeDestroyed, l)
    else if difference > 0 # create new lines in the amount of the quantity difference
      ajax = @createOrderLine(difference)
      ajax.done (newLines)=>
        @lines.push new App.OrderLine(line) for line in newLines
        do @changeRange
      ajax.fail @fail
    else # do quantity difference, try to change the range
      do @changeRange

  changeRange: => 
    if @getStartDate().format("YYYY-MM-DD") != @startDate or @getEndDate().format("YYYY-MM-DD") != @endDate
      ajax = App.OrderLine.changeTimeRange @lines, @getStartDate(), @getEndDate(), @getSelectedInventoryPool()
      ajax.done @done
      ajax.fail @fail
    else
      do @done
