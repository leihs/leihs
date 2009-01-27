class InventoryImport::Paket < ActiveRecord::Base

  belongs_to :geraetepark
  has_many :gegenstands
  
end