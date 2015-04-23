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
  getAvailability: (inventoryPool)=> @availabilities[inventoryPool.id].withoutLines(@reservations)

  # @override
  selectFirstInventoryPool: ->
    id = @reservations[0].inventory_pool_id
    option = @inventoryPoolSelect.find "option[data-id='#{id}']"
    if option.length
      option.prop "selected", true


  # overwrite
  store: =>
    difference = @getQuantity() - @quantity
    if difference < 0  # destroy reservations in the amount of the quantity difference
      reservationsToBeDestroyed = @reservations[0..(Math.abs(difference)-1)]
      deletionDone = _.after reservationsToBeDestroyed.length, @changeRange
      for line in reservationsToBeDestroyed
        do (line)->
          App.Reservation.ajaxChange(line, "destroy", {}).done =>
            line.remove()
            do deletionDone
      @reservations = _.reject @reservations, (l)-> _.include(reservationsToBeDestroyed, l)
    else if difference > 0 # create new reservations in the amount of the quantity difference
      finish = _.after difference, @changeRange
      for time in [1..difference]
        @createReservation()
        .done (datum) =>
          @reservations.push App.Reservation.find datum.id
          do finish
    else # no quantity difference, try to change the range
      do @changeRange

  changeRange: => 
    if @getStartDate().format("YYYY-MM-DD") != @startDate or @getEndDate().format("YYYY-MM-DD") != @endDate
      ajax = App.Reservation.changeTimeRange @reservations, @getStartDate(), @getEndDate(), @getSelectedInventoryPool()
      ajax.done @done
      ajax.fail @fail
    else
      do @done
