class Type < ActiveRecord::Base
  has_many :items
  has_many :order_lines
  
  #TODO: Relation to Inventory Pool?
  
end
