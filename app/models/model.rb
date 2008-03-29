class Model < ActiveRecord::Base
  has_many :items
  has_many :order_lines
  has_many :attributes
  has_many :accessories
  
  #TODO: Relation to Inventory Pool?
  
end
