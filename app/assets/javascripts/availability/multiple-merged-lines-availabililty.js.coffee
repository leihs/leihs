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
      new_entry[0] = date_as_string
      
      # go trough all selected lines availability dates (or last founded entry) that matches the current date to compute the merged availability for this date
      for selected_line in selected_lines
        offset_date = new Date(date)
        last_av_entry = []
        # if the date of the first entry is higher then the offset_date then we assume that there was no out_quantity so the entry is available
        first_date_of_this_line_av = new Date Date.parse(selected_line.availability_for_inventory_pool.availability[0][0].replace(/-/g, "/")+" GMT")
        if first_date_of_this_line_av > offset_date
           new_entry[1] = 1
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
            break
              
      # got entry push it to result
      merged_lines_availabilities.availability.push new_entry
    
    return merged_lines_availabilities
            
window.MultipleMergedLinesAvailabilities = MultipleMergedLinesAvailabilities
