class Model < ActiveRecord::Base
  has_many :items
  has_many :order_lines
  has_many :properties
  has_many :accessories

  has_and_belongs_to_many :packages
  
  acts_as_ferret :fields => [ :name ],
                 :store_class_name => true
  

  #TODO: Relation to Inventory Pool?

  acts_as_ferret #TODO include/exclude fields
  
  
end
