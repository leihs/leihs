ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'

dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/steps/*.rb")].uniq.each do |file|
  require file
end

##
# Run a story file relative to the stories directory.

def run_local_story(filename, options={})
  run File.join(File.dirname(__FILE__), filename), options
end

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
  return fasle if date2.nil?
  date1.day == date2.day && date1.month == date2.month && date1.year == date2.year
end