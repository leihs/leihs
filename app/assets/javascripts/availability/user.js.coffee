###

User Availability 

This script provides functionalities to compute user availability on a given availability_enries
 
###

class UserAvailability
  
  constructor: (availability_enries, user_groups) ->
    @total_rentable = 0
    @user_group_ids = []
    @user_group_ids.push group.id for group in user_groups
    for partition in availability_enries.partitions
      do (partition) => 
        if @user_group_ids.indexOf(partition.group_id) > -1 or partition.group_id is null # push partition with id null because its the group "general"
          @total_rentable += parseInt partition.quantity
    return @ 
            
    
window.UserAvailability = UserAvailability
