class Partition < ActiveRecord::Base
  
  belongs_to :model
  belongs_to :inventory_pool
  belongs_to :group
  
  validates_presence_of :model, :inventory_pool, :quantity
  validates_numericality_of :quantity, :only_integer => true, :greater_than => 0
  
  # also see model.rb->def in(...).
  # Model extends the "partitions" relation at access time with further methods
end
