###
  
  Availability

###

class window.App.Availability extends Spine.Model

  @configure "Availability", "inventory_pool_id", "model_id", "quantity"
  
  @belongsTo "inventory_pool", "App.InventoryPool", "inventory_pool_id"
  @belongsTo "model", "App.Model", "model_id"

  @extend Spine.Model.Ajax

  @url: => "/availability"

  changesBetween: (startDate, endDate)->
    startDate = @mostRecentOrEqualDate startDate
    _.filter @changes, (change)-> moment(change[0]).diff(moment(startDate), "days") >= 0 and moment(change[0]).diff(moment(endDate), "days") <= 0

  mostRecentOrEqualDate: (date) => 
    changesOfPastOrEqual = _.filter @changes, (change)-> moment(change[0]).diff(date, "days") <= 0
    if changesOfPastOrEqual.length
      min = moment(_.min(changesOfPastOrEqual, (change)-> return Math.abs moment(date).diff(change[0], "days"))[0]).toDate()
    else
      min = date
    return min

  maxAvailableForUser: (startDate, endDate, user) =>
    min = _.min @changes.between(startDate, endDate), (change)=> @availabilityForGroups change, groupIds
    if min?
      _.reduce min[2], ((mem, partition) => if @groupIsIn(groupIds, partition.group_id) then mem+partition.in_quantity else mem), 0
    else
      0