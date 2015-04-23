window.App.Reservation.scope = => "/borrow"

window.App.Reservation.changeTimeRange = (reservations, startDate, endDate, inventoryPool)=>
  startDate = moment(startDate).format("YYYY-MM-DD")
  endDate = moment(endDate).format("YYYY-MM-DD")
  for line in reservations
    line.start_date = startDate
    line.end_date = endDate
    line.inventory_pool_id = inventoryPool.id
    App.Reservation.find(line.id).refresh(line)
  $.post "/borrow/reservations/change_time_range",
    line_ids: _.map(reservations,(l)->l.id)
    start_date: startDate
    end_date: endDate
    inventory_pool_id: inventoryPool.id

window.App.Reservation::available = (recover = true)->
  quantity = if @subreservations?
    _.reduce @subreservations, ((mem, l)-> mem + l.quantity), 0
  else
    @quantity
  availability = @model().availabilities().findByAttribute "inventory_pool_id", @inventory_pool_id
  return true unless availability
  if recover
    reservationsToExclude = if @subreservations? then @subreservations else [@]
    availability = availability.withoutLines(reservationsToExclude)
  maxAvailableForUser = availability.maxAvailableForGroups(@start_date, @end_date, App.User.current.groupIds)
  maxAvailableForUser >= quantity