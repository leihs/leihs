class Option < ActiveRecord::Base
  
  belongs_to :order_line
  
  validates_presence_of :name
  validates_presence_of :quantity
  
end
