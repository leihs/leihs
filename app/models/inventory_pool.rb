class InventoryPool < ActiveRecord::Base
  has_many :items
  has_many :access_rights
  
  has_many :models, :through => :items
  has_many :orders
  has_many :contracts
  
end
