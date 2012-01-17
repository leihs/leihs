###

User Availability 

This script provides functionalities to compute user availability on a given inventory_pool
 
###

class UserAvailability
  
  constructor: (inventory_pool, user_groups) ->
    @total_rentable = 0
    @user_group_ids = []
    @user_group_ids.push group.id for group in user_groups
    for partition in inventory_pool.partitions
      do (partition) => 
        if @user_group_ids.indexOf(partition.group_id) > -1 or partition.group_id is null # push partition with id null because its the group "general"
          @total_rentable += parseInt partition.quantity
    return @ 
            
    
window.UserAvailability = UserAvailability
