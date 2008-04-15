class Item < ActiveRecord::Base

  AVAILABLE = 1
  IN_REPAIR = 2

  belongs_to :model
  belongs_to :inventory_pool
  has_many :contract_lines

end
