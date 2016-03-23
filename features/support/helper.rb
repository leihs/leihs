# encoding: utf-8
def link2(attributes)
  "<a href='#{attributes['url']}'>#{attributes['name']}</a>"
end


def find_line(model)
  id = 0
  @contract.reservations.each do |line|
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
    when 'no'  then 0
    when 'a'   then 1
    when 'an'  then 1
    when 'one' then 1
    when 'two' then 2
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
    return eval('' + $1 + '.' + $2 + '.from_now').to_date
  # 20_years_ago
  elsif date =~ /(\d+)_(\w+)_ago/
    return eval('' + $1 + '.' + $2 + '.ago').to_date
  elsif date == 'now'
    return Date.today
  elsif date == 'the_end_of_time'
    return Availability::ETERNITY
  else
    return LeihsFactory.parsedate( date )
  end
end

##############################################################

def get_fullcalendar_day_element(date)
  find("td[data-date='#{date}']")
end

def type_into_autocomplete(selector, value)
  raise 'please provide a value' if value.size.zero?
  step 'I release the focus from this field'
  find(selector).click
  find(selector).set value
  find('.ui-autocomplete')
end

def change_line_start_date(line, days = 2)
  new_start_date = line.start_date + days.days
  get_fullcalendar_day_element(new_start_date).click
  find('.button#set-start-date', text: _('Start date')).click
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
  new_start_date
end

def hover_for_tooltip(target)
  page.driver.browser.action.move_to(target.native).perform
  find('.tooltipster-content') # there should be just one
end
