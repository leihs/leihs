###
  
  Line is a represantative of document lines (order / contract)

###

class Line

  # Merging lines by model is needed to merge multiple selected lines of the same model to display them as one line with increased quantity for the booking calendar.
  # They have an additonal key/vaulue for storing the merged sub line ids called "sublines". 
  # Quantity is getting increased on the base line while merging multiple lines.
  #
  @mergeByModel = (lines)->
    mergedLines = []
    _.each lines, (line)=> 
      lineWithSameModel = _.find mergedLines, (mergedLine)-> mergedLine.model.id == line.model.id
      if lineWithSameModel? and line.model.type != "option"
        lineWithSameModel.quantity += line.quantity
        lineWithSameModel.sublines = [JSON.parse JSON.stringify lineWithSameModel] unless lineWithSameModel.sublines?
        lineWithSameModel.sublines.push JSON.parse JSON.stringify line
        # merge the availability of the merged line while detaching the new subline
        if lineWithSameModel.availability_for_inventory_pool?
          lineWithSameModel.availability_for_inventory_pool.changes = new App.AvailabilityChanges(lineWithSameModel.availability_for_inventory_pool.changes).withoutLines([line]) 
      else
        newLine = JSON.parse(JSON.stringify(line))
        if newLine.availability_for_inventory_pool?
          newLine.availability_for_inventory_pool.changes = new App.AvailabilityChanges(newLine.availability_for_inventory_pool.changes).withoutLines([newLine]) 
        mergedLines.push newLine
    return mergedLines

  # Group multiple lines by date ranges is needed to display them as date range blocks, like on the Acknowledge, HandOver or TakeBack screen.
  # The returning array is a collection of objects in the format: {start_date: XXX, end_date: XXX, lines: []}.
  #
  @groupByDateRanges = (lines)->
    return [] if lines.length is 0
    hash = {}
    (hash[JSON.stringify {start_date: line.start_date, end_date: line.end_date}] ?= []).push(line) for line in lines
    groupedLines = []
    $.each hash, (key, value) ->
      key_obj = JSON.parse key
      groupedLines.push {start_date: key_obj.start_date, end_date: key_obj.end_date, lines: value}
    groupedLines.sort (a,b)->
      if moment(a.start_date).toDate() < moment(b.start_date).toDate()
        return false
      else if moment(a.start_date).sod().diff(moment(b.start_date).sod(), "days") == 0
        if moment(a.end_date).toDate() < moment(b.end_date).toDate()
          return false
        else if moment(a.end_date).sod().diff(moment(b.end_date).sod(), "days") == 0
          return false
        else
          return true
      else
        return true 
    return groupedLines 

  # Get the max (end) date of an array of lines
  #
  @getMaxDate = (lines)->
    max_dates = []
    max_dates.push moment(line.end_date).toDate() for line in lines
    max_date = max_dates.reduce (a,b) -> Math.max(a, b)
    max_date = new Date(max_date)
    return max_date

  # Get the max quantity of an array of lines
  #
  @getMaxQuantity = (lines)->
    _.reduce lines, ((mem, line) -> mem + line.quantity), 0

  # Get the max range of an array of lines
  #
  @getMaxRange = (lines)->
    return 0 if lines.length is 0
    max_ranges = []
    max_ranges.push moment(line.end_date).eod().diff(moment(line.start_date).sod(),"days") for line in lines
    return Math.round max_ranges.reduce (a,b) -> Math.max(a, b)

  # Get the min date of an array of lines
  #
  @getMinDate = (lines)->
    min_dates = []
    min_dates.push moment(line.start_date).sod().toDate() for line in lines
    min_date = min_dates.reduce (a,b) -> Math.min(a, b)
    return min_date

window.App.Line = Line