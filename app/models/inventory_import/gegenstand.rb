class InventoryImport::Gegenstand < ActiveRecord::Base

  belongs_to :paket
  belongs_to :kaufvorgang
end