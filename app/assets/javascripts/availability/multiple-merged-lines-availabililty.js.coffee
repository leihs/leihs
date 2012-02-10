###

Multiple Merged Lines Availabilities

This script provides functionalities to compute/merge multiple availability dates containers to a single one
we only care if a merged availabililty is 0 or greater then 0, we dont care about exact numbers
 
###

class MultipleMergedLinesAvailabilities
  
  constructor: (selected_lines) ->
    # prepare the returning format:  availability, partitions and inventory_pool
    merged_lines_availabilities = {}
    merged_lines_availabilities.availability = []
    merged_lines_availabilities.partitions = []
    merged_lines_availabilities.inventory_pool = selected_lines[0].availability_for_inventory_pool.inventory_pool
    
    # make a union of all possible partitions
    for line in selected_lines
      for partition in line.availability_for_inventory_pool.partitions
        existing_partition = (existing_partition for existing_partition in merged_lines_availabilities.partitions when partition.group_id is existing_partition.group_id)[0]
        if not existing_partition?
          merged_lines_availabilities.partitions.push partition
    
    # go trough all selected lines to just collect the possible existing availability dates first (before merging anything)
    summed_av_dates = []
    for line in selected_lines
      for av_date in line.availability_for_inventory_pool.availability
        summed_av_dates.push av_date[0] if summed_av_dates.indexOf(av_date[0]) < 0
    
    # sort summed_av_dates by date increasing
    summed_av_dates = summed_av_dates.sort (a,b)->
      return (new Date Date.parse(a.replace(/-/g, "/")+" GMT"))-(new Date Date.parse(b.replace(/-/g, "/")+" GMT"))
    
    # go trough all summed_av_dates now to merge all selected_lines availability dates
    for date_as_string in summed_av_dates
      date = new Date Date.parse(date_as_string.replace(/-/g, "/")+" GMT")
      new_entry = []
      new_entry[0] = date_as_string # date as string (e.g. "2012-01-13")
      new_entry[2] = [] # partitions
      
      # go trough all selected lines availability dates (or last founded entry) that matches the current date to compute the merged availability for this date
      for selected_line in selected_lines
        offset_date = new Date(date)
        last_av_entry = []
        # if the date of the first entry is higher then the offset_date then we assume that there was no out_quantity so the entry is available
        first_date_of_this_line_av = new Date Date.parse(selected_line.availability_for_inventory_pool.availability[0][0].replace(/-/g, "/")+" GMT")
        if first_date_of_this_line_av > offset_date
          new_entry[1] = 1
          # force all partitions to become available as well
          for partition in merged_lines_availabilities.partitions
            new_partition = 
              group_id: partition.group_id
              in_quantity: 1
            new_entry[2].push new_partition
          break # for selected_line in selected_lines
        else
          while last_av_entry.length is 0
            for av_entry in selected_line.availability_for_inventory_pool.availability
              av_date = new Date Date.parse(av_entry[0].replace(/-/g, "/")+" GMT")
              if av_date.toDateString() == offset_date.toDateString()
                last_av_entry = av_entry
                break
            offset_date.setDate(offset_date.getDate()-1)
          # got last entry
          # set new_entry total quantity depending of value of last av_entry
          new_entry[1] = if last_av_entry[1] <= 0 then 0 else 1
          if new_entry[1] <= 0
            # force all partitions to become zero as well
            # set new_entry partitions by merging partitions (involve all unified partitions)
            for partition in merged_lines_availabilities.partitions
              new_partition = 
                group_id: partition.group_id
                in_quantity: 0
              new_entry[2].push new_partition
            break
          else # new entry has total quantity greater then 0
            # set new_entry partitions by merging partitions (involve all unified partitions)
            for partition in merged_lines_availabilities.partitions
              last_av_entry_maching_partitions = (last_av_partition for last_av_partition in last_av_entry[2] when partition.group_id is last_av_partition.group_id)
              last_av_entry_maching_partition = if last_av_entry_maching_partitions.length > 0 then last_av_entry_maching_partitions[0] else undefined
              new_entry_matching_partitions = (new_entry_partition for new_entry_partition in new_entry[2] when partition.group_id is new_entry_partition.group_id)
              new_entry_matching_partition = if new_entry_matching_partitions.length > 0 then new_entry_matching_partitions[0] else undefined
              if new_entry_matching_partition? # partition entry alerady existing for the new entry
                if not last_av_entry_maching_partition?
                  new_entry_matching_partition.in_quantity = 0
                else 
                  new_entry_matching_partition.in_quantity = if new_entry_matching_partition.in_quantity == 0 or last_av_entry_maching_partition.in_quantity == 0 then 0 else 1
              else # new partition not matching any partition inside of the new entry
                computed_in_quantity = if not last_av_entry_maching_partition? or last_av_entry_maching_partition.in_quantity <= 0 then 0 else 1
                new_partition = 
                  group_id: partition.group_id
                  in_quantity: computed_in_quantity
                new_entry[2].push new_partition
              
              
      # got entry push it to result
      merged_lines_availabilities.availability.push new_entry
    
    return merged_lines_availabilities
            
window.MultipleMergedLinesAvailabilities = MultipleMergedLinesAvailabilities
