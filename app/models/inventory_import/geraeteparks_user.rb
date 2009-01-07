class InventoryImport::GeraeteparksUser < ActiveRecord::Base

  belongs_to :geraetepark
  belongs_to :user
end