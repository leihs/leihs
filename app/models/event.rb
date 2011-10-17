# == Schema Information
#
# Table name: events
#
#  date              :date            default(Tue, 07 Dec 2010)
#  title             :string          default("")
#  action            :string          default("hand_over")
#  quantity          :integer         default(0)
#  contract_line_ids :string
#

# This represents a date associated with a customer on which something
# particular happens with customer's contracts.
#
# It can be the fact that the customer should come to pick up items
# because they are reserved from that date on.
#
# Another Event could represent the date on which the customer should
# return Items because they only were reserved up to that date.
#
# Etc.
#
# The Event object does not contain a reference to what exactly it is
# that would happen on that date. As such it is up to the user of the
# event to give it a meaning.
#
# Events do not have a corresponding database table associated with them
# a accordingly are not persistent!
#
# TODO drop completely this class!!!
class Event
  
  attr_accessor :date, # :date, Date.today
                :title, # :string, ""
                :action, # :string, "hand_over"
                :quantity, # :integer, 0
                :contract_line_ids, # :string, nil # Array
                :inventory_pool,
                :user

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    @date ||= Date.today
    @title ||= ""
    @action ||= "hand_over"
    @quantity ||= 0
    @contract_line_ids ||= []
  end
  
  def as_json(options={})
    #split first in optionlines and itemlines
    
    lines_array = contract_lines.map {|cl| OpenStruct.new({:start_date => cl.start_date, :end_date => cl.end_date, :model => cl.model, :quantity => cl.quantity}) }
    
    sorted_and_grouped_contract_lines = lines_array.sort {|a,b| [a.start_date, a.end_date, a.model.id] <=> [b.start_date, b.end_date, b.model.id] }.
                                          group_by {|cl| [cl.start_date, cl.end_date, cl.model] }
    
    lines_hash = sorted_and_grouped_contract_lines.map {|k,v| {:start_date => k[0],
                                                      :end_date => k[1],
                                                      :model => {:name => k[2].name, :manufacturer => k[2].manufacturer}, :quantity => v.sum(&:quantity)} }
    latest_remind = user.reminders.last
    
    {:title => title,
     :contract_lines => lines_hash,
     :user => user,
     :inventory_pool => inventory_pool,
     :quantity => quantity,
     :date => date,
     :latest_remind => (latest_remind and latest_remind.created_at > date) ? latest_remind.created_at.to_s(:db) : nil,
     :min_date => lines_hash.min {|x| x[:start_date]}[:start_date],
     :max_date => lines_hash.max {|x| x[:end_date]}[:end_date],
    }
  end
  
  # OPTIMIZE
  def contract_lines
    @contract_lines ||= ContractLine.where(:id => contract_line_ids)
  end
  
  # alias
  def lines
    contract_lines
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.date <=> other.date
  end  

end
