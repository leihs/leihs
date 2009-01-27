class InventoryImport::Reservation < ActiveRecord::Base

  belongs_to :user
  belongs_to :geraetepark
  has_and_belongs_to_many :pakets
  
end
  

