
class Availability

  @changes

  constructor: (changes)->
    @changes = changes

  isAvailable: (startDate, endDate, quantity, groupIds) -> 
    if groupIds?
      @maxAvailableForGroups(startDate, endDate, groupIds) >= quantity
    else
      @maxAvailableInTotal(startDate, endDate) >= quantity
    
  maxAvailableInTotal: (startDate, endDate) => 
    changes = @changesBetween(startDate, endDate)
    if changes.length
      _.min(changes, (change)-> change[1])[1]
    else
      0
  
  maxAvailableForGroups: (startDate, endDate, groupIds) =>
    groupIsIn = (groupIds, groupId) -> _.include(groupIds, groupId) or groupId == 0 or groupId == null
    min = _.min @changesBetween(startDate, endDate), (change)-> 
      availabilityForGroups = _.reduce change[2], ((mem, partition)-> if groupIsIn(groupIds, partition.group_id) then mem+partition.in_quantity else mem), 0 
    if min?
      _.reduce min[2], ((mem, partition) -> if groupIsIn(groupIds, partition.group_id) then mem+partition.in_quantity else mem), 0
    else
      0

  changesBetween: (startDate, endDate) =>
    startDate = @mostRecentOrEqualDate startDate
    _.filter @changes, (change)-> moment(change[0]).diff(moment(startDate), "days") >= 0 and moment(change[0]).diff(moment(endDate), "days") <= 0

  mostRecentOrEqualDate: (date)=> 
    changesOfPastOrEqual = _.filter @changes, (change)-> moment(change[0]).diff(date, "days") <= 0
    if changesOfPastOrEqual.length
      min = moment(_.min(changesOfPastOrEqual, (change)-> return Math.abs moment(date).diff(change[0], "days"))[0]).toDate()
    else
      min = date
    return min

window.App.Availability = Availability