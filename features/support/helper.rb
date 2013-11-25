def link2(attributes)
  "<a href='#{attributes['url']}'>#{attributes['name']}</a>"
end


def find_line(model)
  id = 0
  @contract.lines.each do |line|
    if model == line.model.name
      return line
    end
  end
  nil
end

def available_quantities_between(from, to, available_quantities)
  if available_quantities.count == 1
    if from >= available_quantities.first.date
      return available_quantities
    else 
      return []
    end
  else
    aq = available_quantities.select do |available_quantity|
           available_quantity.date >= from and available_quantity.date <= to 
         end
    return aq
  end
end

def to_number( number )
  case number
    when "no"  then 0
    when "a"   then 1
    when "an"  then 1
    when "one" then 1
    when "two" then 2
  else
    number.to_i
  end
end

# transform all kinds of date strings to Date objects
# including:
#  20_days_ago and 2_day_from_now
def to_date( date )
  # 20_days_from_now
  if date =~ /(\d+)_(\w+)_from_now/
    return eval("" + $1 + "." + $2 + ".from_now").to_date
  # 20_years_ago
  elsif date =~ /(\d+)_(\w+)_ago/
    return eval("" + $1 + "." + $2 + ".ago").to_date
  elsif date == "now"
    return Date.today
  elsif date == "the_end_of_time"
    return Availability::ETERNITY
  else
    return LeihsFactory.parsedate( date )
  end
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

##############################################################
#
# Date changing hackery

def back_to_the_future(date)
  Timecop.travel(date)
  change_database_current_date
end

def back_to_the_present
  Timecop.return
  change_database_current_date
end

def change_database_current_date
  # The minimum representable time is 1901-12-13, and the maximum representable time is 2038-01-19
  ActiveRecord::Base.connection.execute "SET TIMESTAMP=unix_timestamp('#{Date.today.to_s}')"
end

##############################################################

def get_fullcalendar_day_element(date)
  find("td[data-date='#{date}']")
end

def type_into_autocomplete(selector, value)
  raise "please provide a value" if value.size.zero?
  find("body").click # blur all possible focused autocomplete inputs
  find(selector).set value
  find(".ui-autocomplete")
end

def change_line_start_date(line, days = 2)
  new_start_date = line.start_date + days.days
  get_fullcalendar_day_element(new_start_date).click
  find(".button#set-start-date", :text => _("Start Date")).click
  step 'I save the booking calendar'
  new_start_date
end
