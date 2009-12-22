class Event < ActiveRecord::Base
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  column :start, :date, Date.today
  column :end, :date, Date.today
  column :title, :string, ""
  column :isDuration, :boolean, true
  column :action, :string, "hand_over"
  column :quantity, :integer, 0

  has_one :inventory_pool
  has_one :user
  has_many :contract_lines                

  # alias
  def lines
    contract_lines
  end

  #alias
  def date
    start
  end
  
  def quantity
    self.contract_lines.collect(&:quantity).sum
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.date <=> other.date
  end  

end

