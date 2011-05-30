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
  
  # OPTIMIZE
  def contract_lines
    @contract_lines ||= ContractLine.all(:conditions => {:id => contract_line_ids})
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
