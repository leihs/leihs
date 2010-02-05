def link2(attributes)
  "<a href='#{attributes['url']}'>#{attributes['name']}</a>"
end


def find_line(model)
  id = 0
  @order.order_lines.each do |line|
    if model == line.model.name
      return line
    end
  end
  nil
end

def get_period(from, to, periods)
#  puts "Searching: #{from.day}.#{from.month}.#{from.year} - #{to.day}.#{to.month}.#{to.year}" if to != nil
  periods.each do |period|
#    puts "Comparing: #{period.start_date.day}.#{period.start_date.month}.#{period.start_date.year} - #{period.end_date.day}.#{period.end_date.month}.#{period.end_date.year}" if period.end_date != nil
    return period if (same_day(period.start_date, from) && same_day(period.end_date, to)) 
  end
  nil
end

def same_day(date1, date2)
  return true if date1.nil? and date2.nil?
  return false if date1.nil?
  return false if date2.nil?
  date1.day == date2.day && date1.month == date2.month && date1.year == date2.year
end

##############################################################
#

def include_in_collection?(element, collection)
  #collection.include? element  # TODO override == in the model OrderLine
  
  # TODO iterate dynamically the relevant attributes, write as generic
  #attribs = element.attribute_names
  #["id", "created_at", "update_at"].each { |x| attribs.delete x }

  e = element
  r = collection.detect { |c| c.end_date == e.end_date and
                          c.model_id == e.model_id and
                          c.order_id == e.order_id and
                          c.quantity == e.quantity and
                          c.start_date == e.start_date }
  !r.nil?
end

def equal_collections?(coll_a, coll_b)
    r = true
    r = (r and (coll_a.size == coll_b.size))
    coll_a.each do |a|
      r = (r and include_in_collection? a, coll_b)
    end 
    r
end

#
##############################################################
