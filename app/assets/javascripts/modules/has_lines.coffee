App.Modules.HasLines = 

  getMaxDate: ->
    max_dates = []
    max_dates.push moment(reservation.end_date).toDate() for reservation in @reservations().all()
    max_date = max_dates.reduce (a,b) -> Math.max(a, b)
    new Date(max_date)

  getMaxRange: -> 
    return 0 if @reservations().all().length is 0
    max_ranges = []
    max_ranges.push moment(reservation.end_date).endOf("day").diff(moment(reservation.start_date).startOf("day"),"days") for reservation in @reservations().all()
    1+max_ranges.reduce (a,b) -> Math.max(a, b)

  #
  # Group multiple reservations by date ranges is needed to display them as date range blocks, like on the Acknowledge, HandOver or TakeBack screen.
  # The returning array is a collection of objects in the format: {start_date: XXX, end_date: XXX, reservations: []}.
  #
  groupedLinesByDateRange: (mergeModels = false)->
    @groupByDateRange @reservations().all(), mergeModels

  groupByDateRange: (reservations, mergeModels = false, actionDate = false)->
    return [] if reservations.length is 0
    hash = {}
    (hash[JSON.stringify {start_date: reservation.start_date, end_date: reservation.end_date}] ?= []).push(reservation) for reservation in reservations
    result = []
    $.each hash, (key, value) ->
      key_obj = JSON.parse key
      reservations = if mergeModels then App.Modules.HasLines.mergeLinesByModel(value) else value

      # sort reservations by model name and id
      reservations = _.sortBy reservations, (r)-> r.model().name()
      groupedReservations = _.groupBy reservations, (r) -> r.model().name()
      groupedReservations = \
        _.mapObject(groupedReservations,
                    (reservations, _) -> reservations.sort((r1, r2) -> r1.id - r2.id))
      reservations = _.flatten _.values(groupedReservations)

      result.push {start_date: key_obj.start_date, end_date: key_obj.end_date, reservations: reservations}
    result.sort (a,b)->
      if moment(a.start_date).toDate() < moment(b.start_date).toDate()
        return false
      else if moment(a.start_date).startOf("day").diff(moment(b.start_date).startOf("day"), "days") == 0
        if moment(a.end_date).toDate() < moment(b.end_date).toDate()
          return false
        else if moment(a.end_date).startOf("day").diff(moment(b.end_date).startOf("day"), "days") == 0
          return false
        else
          return true
      else
        return true
    if actionDate
      hash = {}
      (hash[JSON.stringify {date: group[actionDate]}] ?= []).push(group) for group in result
      result = []
      $.each hash, (key, value) ->
        key_obj = JSON.parse key
        result.push {date: key_obj.date, groups: value}
      result = _.sortBy result, (el) -> el.date
    return result

  groupByDateAndPool: (reservations, mergeModels = false)->
    merge = _.groupBy reservations, (l)-> JSON.stringify({start_date: l.start_date, inventory_pool_id: l.inventory_pool_id})
    for k, v of merge
      merge[k] = _.chain(v)
      .sortBy((l)-> l.model().name())
      .groupBy((l)-> JSON.stringify {model_id: l.model_id, end_date: l.end_date})
      .value()
      merge[k] = _(merge[k]).values().map (reservations)-> {reservations: if mergeModels then App.Modules.HasLines.mergeLinesByModel(reservations) else reservations}
    result = []
    for k, v of merge
      result.push
        inventory_pool: App.InventoryPool.find JSON.parse(k).inventory_pool_id
        start_date: JSON.parse(k).start_date
        groups: v
    result = _.sortBy result, (e)-> e.start_date
    return result

  #
  # Merging reservations by model is needed to merge multiple selected reservations of the same model to display them as one reservation with increased quantity for the booking calendar.
  # They have an additonal key/vaulue for storing the merged sub reservation ids called "subreservations".
  #
  mergedLinesByModel: ->
    return @mergeLinesByModel @reservations().all()

  mergeLinesByModel: (reservations)->
    result = []
    _.each reservations, (reservation) =>
      reservation = $.extend(true, {}, reservation)
      reservation.ids = [reservation.id]
      existingLine = _.find(result, (l)-> l.model_id is reservation.model_id) if reservation.model_id?
      if existingLine?
        existingLine.subreservations = [existingLine] unless existingLine.subreservations?
        existingLine.subreservations.push reservation
        existingLine.ids.push reservation.id
      else
        result.push reservation
    return result
