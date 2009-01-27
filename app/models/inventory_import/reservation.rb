class InventoryImport::Reservation < ActiveRecord::Base

  belongs_to :user, :class_name => "InventoryImport::User"
  belongs_to :geraetepark
  has_and_belongs_to_many :pakets
  
end
  

