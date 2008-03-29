class InventoryPool < ActiveRecord::Base
  has_many :items
  has_many :access_rights
end
