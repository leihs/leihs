###
  
  Changes on the availability.

###

class AvailabilityChanges

  constructor: (changes)->
    return undefined unless changes?
    changes = JSON.parse(JSON.stringify(changes))
    endDateOf = (change) =>
      index = changes.indexOf change
      if index >= changes.length-1
        Infinity
      else
        moment(changes[index+1][0]).subtract("days", 1).format("YYYY-MM-DD")
    @changes = changes
    for change in @changes
      change[3] = endDateOf change

  # remove a specific DocumentLine (type: orderLine/contractLine) from the availability changes to unblock/free things
  withoutSpecificDocumentLines: (lines) =>
    lines = JSON.parse(JSON.stringify(lines))
    _.map @changes, (change)=>
      change = JSON.parse JSON.stringify change
      for allocation in change[2]
        for line in lines
          type = _.str.classify line.type
          if allocation.out_document_lines? and allocation.out_document_lines[type]?
            outDocumentLines = allocation.out_document_lines[type]
            if outDocumentLines? and _.include(outDocumentLines, line.id)
              allocation.out_document_lines[type] = _.filter outDocumentLines, (l)-> l != line.id
              allocation.in_quantity += line.quantity
              change[1] += line.quantity
      return change

  between: (startDate, endDate) =>
    startDate = @mostRecentOrEqualDate startDate
    _.filter @changes, (change)-> moment(change[0]).diff(moment(startDate), "days") >= 0 and moment(change[0]).diff(moment(endDate), "days") <= 0

  mostRecentOrEqualDate: (date) => 
    changesOfPastOrEqual = _.filter @changes, (change)-> moment(change[0]).diff(date, "days") <= 0
    if changesOfPastOrEqual.length
      min = moment(_.min(changesOfPastOrEqual, (change)-> return Math.abs moment(date).diff(change[0], "days"))[0]).toDate()
    else
      min = date
    return min

window.App.AvailabilityChanges = AvailabilityChanges