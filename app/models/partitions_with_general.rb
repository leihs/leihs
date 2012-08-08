class PartitionsWithGeneral < ActiveRecord::Base

  belongs_to :model
  belongs_to :inventory_pool
  belongs_to :group
  
end
