###
  
  Everything is about availability.

###

class Availability

  constructor: (availability, line)->
    availability = JSON.parse(JSON.stringify(availability))
    if line?
      @changes = new App.AvailabilityChanges(availability.changes).removeLines [line]
    else
      @changes = new App.AvailabilityChanges availability.changes
    @documentLines = availability.documentLines
    @partitions = availability.partitions

  isAvailable: (startDate, endDate, quantity, groupIds) ->
    if groupIds?
      @maxAvailableForGroups(startDate, endDate, groupIds) >= quantity
    else
      @maxAvailableInTotal(startDate, endDate) >= quantity
    
  maxAvailableInTotal: (startDate, endDate) =>
    changes = @changes.between(startDate, endDate)
    if changes.length
      _.min(changes, (change)-> change[1])[1]
    else
      0

  unavailableRanges: (quantity, groupIds, startDate, endDate) =>
    unavailableRanges = []
    changes = @changes.between(startDate, endDate)
    _.each changes, (change, i)=>
      quantity_to_check = if groupIds then @availabilityForGroups(change, groupIds) else change[1] # get total quantity when groupIds are not defined
      if quantity_to_check < quantity
        rangesStartDate = if moment(change[0]).diff(moment(startDate), "days") < 0 then startDate else change[0] 
        rangesEndDate = if moment(change[3]).diff(moment(endDate), "days") > 0 then endDate else change[3] 
        unavailableRange = [moment(rangesStartDate).format("YYYY-MM-DD"),moment(rangesEndDate).format("YYYY-MM-DD")]
        # merge range with a previous range if end_date of range 1 is equal with start_date of range 2
        rangeToBeMerged = _.find unavailableRanges, (range)-> range[1] == moment(unavailableRange[0]).subtract("days", 1).format("YYYY-MM-DD")
        if rangeToBeMerged?
          rangeToBeMerged[1] = unavailableRange[1]
        else
          unavailableRanges.push unavailableRange
    return unavailableRanges

  getDocumentLine: (id) => _.find @documentLines, (line)-> line.id == id

  groupIsIn: (groupIds, groupId) => _.include(groupIds, groupId) or groupId == 0 or groupId == null

  maxAvailableForGroups: (startDate, endDate, groupIds) =>
    min = _.min @changes.between(startDate, endDate), (change)=> @availabilityForGroups change, groupIds
    if min?
      _.reduce min[2], ((mem, partition) => if @groupIsIn(groupIds, partition.group_id) then mem+partition.in_quantity else mem), 0
    else
      0

  availabilityForGroups: (change, groupIds) =>
    _.reduce change[2], ((mem, partition)=> if @groupIsIn(groupIds, partition.group_id) then mem+partition.in_quantity else mem), 0 

window.App.Availability = Availability