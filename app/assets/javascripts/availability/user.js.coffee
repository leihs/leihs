###

User Availability 

This script provides functionalities to compute user availability on a given availability_entries
 
###

class UserAvailability
  
  constructor: (availability_entries, user_groups) ->
    @total_rentable = 0
    @user_group_ids = [0] # explicitly including the general group 
    @user_group_ids.push group.id for group in user_groups
    for partition in availability_entries.partitions
      do (partition) => 
        if @user_group_ids.indexOf(partition.group_id) > -1 or partition.group_id is null # push partition with id null because its the group "general"
          @total_rentable += parseInt partition.quantity
    return @ 
    
window.UserAvailability = UserAvailability
