###
  
  Availability

  more complex availability (including changes)
  needed for the booking calendar

###

class window.App.Availability extends Spine.Model

  @configure "Availability", "inventory_pool_id", "model_id", "changes", "total_borrowable"
  
  @belongsTo "inventory_pool", "App.InventoryPool", "inventory_pool_id"
  @belongsTo "model", "App.Model", "model_id"

  @extend Spine.Model.Ajax

  availabilityForGroups: (change, groupIds) =>
    _.reduce change[2], ((mem, partition)=> if @groupIsIn(groupIds, partition.group_id) then mem+partition.in_quantity else mem), 0 

  changesBetween: (startDate, endDate)->
    startDate = @mostRecentOrEqualDate startDate
    _.filter @changes, (change)-> moment(change[0]).diff(moment(startDate), "days") >= 0 and moment(change[0]).diff(moment(endDate), "days") <= 0

  groupIsIn: (groupIds, groupId) => _.include(groupIds, groupId) or groupId == 0 or groupId == null

  maxAvailableForGroups: (startDate, endDate, groupIds)=>
    min = _.min @changesBetween(startDate, endDate), (change)=> @availabilityForGroups change, groupIds
    if min?
      _.reduce min[2], ((mem, partition) => if @groupIsIn(groupIds, partition.group_id) then mem+partition.in_quantity else mem), 0
    else
      0

  maxAvailableInTotal: (startDate, endDate) =>
    changes = @changesBetween(startDate, endDate)
    if changes.length
      _.min(changes, (change)-> change[1])[1]
    else
      0

  mostRecentOrEqualDate: (date) => 
    changesOfPastOrEqual = _.filter @changes, (change)-> moment(change[0]).diff(date, "days") <= 0
    if changesOfPastOrEqual.length
      min = moment(_.min(changesOfPastOrEqual, (change)-> return Math.abs moment(date).diff(change[0], "days"))[0]).toDate()
    else
      min = date
    return min

  withoutLines: (lines) =>
    lines = _.clone lines
    changes = _.map @changes, (change)=>
      change = _.clone change
      for allocation in change[2]
        for line in lines
          if allocation.out_document_lines? and allocation.out_document_lines[line.constructor.className]?
            outDocumentLines = allocation.out_document_lines[line.constructor.className]
            if _.include(outDocumentLines, line.id)
              allocation.out_document_lines[line.constructor.className] = _.filter outDocumentLines, (l)-> l != line.id
              allocation.in_quantity += line.quantity
              change[1] += line.quantity
      return change
    return _.extend _.clone(@), {changes: changes}