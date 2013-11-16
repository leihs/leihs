App.Modules.HasLines = 

  getMaxDate: ->
    max_dates = []
    max_dates.push moment(line.end_date).toDate() for line in @lines().all()
    max_date = max_dates.reduce (a,b) -> Math.max(a, b)
    new Date(max_date)

  getMaxRange: -> 
    return 0 if @lines().all().length is 0
    max_ranges = []
    max_ranges.push moment(line.end_date).endOf("day").diff(moment(line.start_date).startOf("day"),"days") for line in @lines().all()
    1+max_ranges.reduce (a,b) -> Math.max(a, b)

  #
  # Group multiple lines by date ranges is needed to display them as date range blocks, like on the Acknowledge, HandOver or TakeBack screen.
  # The returning array is a collection of objects in the format: {start_date: XXX, end_date: XXX, lines: []}.
  #
  groupedLinesByDateRange: (mergeModels = false)->
    @groupByDateRange @lines().all(), mergeModels

  groupByDateRange: (lines, mergeModels = false, actionDate = false)->
    return [] if lines.length is 0
    hash = {}
    (hash[JSON.stringify {start_date: line.start_date, end_date: line.end_date}] ?= []).push(line) for line in lines
    result = []
    $.each hash, (key, value) ->
      key_obj = JSON.parse key
      lines = if mergeModels then App.Modules.HasLines.mergeLinesByModel(value) else value
      lines = _.sortBy lines, (l)-> l.model().name
      result.push {start_date: key_obj.start_date, end_date: key_obj.end_date, lines: lines}
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
    return result

  groupByDateAndPool: (lines, mergeModels = false)->
    merge = _.groupBy lines, (l)-> JSON.stringify({start_date: l.start_date, inventory_pool_id: l.contract().inventory_pool_id})
    for k, v of merge
      merge[k] = _.chain(v)
      .sortBy((l)-> l.model().name)
      .groupBy((l)-> JSON.stringify {model_id: l.model_id, end_date: l.end_date})
      .value()
      merge[k] = _(merge[k]).values().map (lines)-> {lines: if mergeModels then App.Modules.HasLines.mergeLinesByModel(lines) else lines}
    result = []
    for k, v of merge
      result.push
        inventory_pool: App.InventoryPool.find JSON.parse(k).inventory_pool_id
        start_date: JSON.parse(k).start_date
        groups: v
    result = _.sortBy result, (e)-> e.start_date
    return result

  #
  # Merging lines by model is needed to merge multiple selected lines of the same model to display them as one line with increased quantity for the booking calendar.
  # They have an additonal key/vaulue for storing the merged sub line ids called "sublines". 
  #
  mergedLinesByModel: ->
    return @mergeLinesByModel @lines().all()

  mergeLinesByModel: (lines)->
    result = []
    _.each lines, (line) => 
      line = $.extend(true, {}, line)
      line.ids = [line.id]
      existingLine = _.find(result, (l)-> l.model_id is line.model_id) if line.model_id?
      if existingLine?
        existingLine.sublines = [existingLine] unless existingLine.sublines?
        existingLine.sublines.push line
        existingLine.ids.push line.id
      else
        result.push line
    return result
