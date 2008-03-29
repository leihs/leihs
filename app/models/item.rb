class Item < ActiveRecord::Base
  belongs_to :model
  belongs_to :inventory_pool
  has_many :contract_lines
end
