###

Merged Multiple Lines Availabililties

This script provides functionalities to compute/merge multiple availability dates containers to a single one
we only care if a merged availabililty is 0 or greater then 0, we dont care about exact numbers
 
###

class MergedMultipleLinesAvailability
  
  constructor: (selected_lines) ->
    # clone the first availability
    merged_lines = selected_lines[0]
    # reset availability
    merged_lines.availability_for_inventory_pool.availability = []
    # reset partitions
    merged_lines.availability_for_inventory_pool.partitions = []
    # go trough all selected lines
    for line in selected_lines
      do (line) ->
        # merge all partitions
        for new_partition in line.availability_for_inventory_pool.partitions
          do (new_partition) ->
            existing_partition = (existing_partition for existing_partition in merged_lines.availability_for_inventory_pool.partitions when new_partition.group_id is existing_partition.group_id)[0]
            if not existing_partition?
              merged_lines.availability_for_inventory_pool.partitions.push new_partition
            
        # merge all availability dates
        for new_av in line.availability_for_inventory_pool.availability
          do (new_av) ->
            # check if entry for this date already exists
            existing_entry = (existing_av for existing_av in merged_lines.availability_for_inventory_pool.availability when new_av[0] is existing_av[0])[0]
            if existing_entry?
              # merge total
              existing_entry[1] = 0 if new_av[1] <= 0 or existing_entry <= 0
              # merge partitions
              for new_partition in new_av[2]
                do (new_partition) ->
                  existing_partition = (existing_partition for existing_partition in existing_entry[2] when existing_partition.group_id is new_partition.group_id)[0]
                  if existing_partition?
                    existing_partition.in_quantity = 0 if new_partition.in_quantity <= 0 or existing_partition.in_quantity <= 0
                  else
                    existing_entry[2].push new_partition         
            else
              merged_lines.availability_for_inventory_pool.availability.push new_av
    return merged_lines
            
window.MergedMultipleLinesAvailability = MergedMultipleLinesAvailability
