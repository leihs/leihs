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

# TODO 2104** merge this helper.rb to /spec/spec_helper.rb? currently is not included!

#sellittf#
# forces live update even in test environment (Rspec-Rails without transactions)
class ActiveRecordSafetyListener
  @@last_dump = nil
  
  def scenario_started(*args)
    @@last_dump ||= ActiveRecord::Base.connection.dump_database
  end

  def scenario_succeeded(*args)
    ActiveRecord::Base.connection.restore_database @@last_dump
  end
end
