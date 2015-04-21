class window.App.ReservationsChangeController extends window.App.BorrowBookingCalendarDialogController

  createReservation: =>
    reservation = new App.Reservation
      model_id: @modelId
      start_date: @getStartDate().format("YYYY-MM-DD")
      end_date: @getEndDate().format("YYYY-MM-DD")
      inventory_pool_id: @getSelectedInventoryPool().id
      quantity: 1
    App.Reservation.ajaxChange(reservation, "create", {})

  # overwrite
  done: (data)=>
    for contract in App.Contract.currents
      App.Contract.trigger "refresh", contract
    super

  # overwrite
  getAvailability: (inventoryPool)=> @availabilities[inventoryPool.id].withoutLines(@lines)

  # @override
  selectFirstInventoryPool: ->
    id = @lines[0].inventory_pool_id
    option = @inventoryPoolSelect.find "option[data-id='#{id}']"
    if option.length
      option.prop "selected", true


  # overwrite
  store: =>
    difference = @getQuantity() - @quantity
    if difference < 0  # destroy lines in the amount of the quantity difference
      linesToBeDestroyed = @lines[0..(Math.abs(difference)-1)]
      deletionDone = _.after linesToBeDestroyed.length, @changeRange
      for line in linesToBeDestroyed
        do (line)->
          App.Reservation.ajaxChange(line, "destroy", {}).done =>
            line.remove()
            do deletionDone
      @lines = _.reject @lines, (l)-> _.include(linesToBeDestroyed, l)
    else if difference > 0 # create new lines in the amount of the quantity difference
      finish = _.after difference, @changeRange
      for time in [1..difference]
        @createReservation()
        .done (datum) =>
          @lines.push App.Reservation.find datum.id
          do finish
    else # no quantity difference, try to change the range
      do @changeRange

  changeRange: => 
    if @getStartDate().format("YYYY-MM-DD") != @startDate or @getEndDate().format("YYYY-MM-DD") != @endDate
      ajax = App.Reservation.changeTimeRange @lines, @getStartDate(), @getEndDate(), @getSelectedInventoryPool()
      ajax.done @done
      ajax.fail @fail
    else
      do @done
