# == Schema Information
#
# Table name: events
#
#  date              :date            default(Tue, 16 Nov 2010)
#  title             :string          default("")
#  action            :string          default("hand_over")
#  quantity          :integer         default(0)
#  contract_line_ids :string
#  date              :date            default(Tue, 16 Nov 2010)
#  title             :string          default("")
#  action            :string          default("hand_over")
#  quantity          :integer         default(0)
#  contract_line_ids :string
#

# TODO drop completely this class!!!
class Event < ActiveRecord::Base
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  column :date, :date, Date.today
  column :title, :string, ""
  column :action, :string, "hand_over"
  column :quantity, :integer, 0
  column :contract_line_ids, :string, nil # Array

  has_one :inventory_pool
  has_one :user

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


