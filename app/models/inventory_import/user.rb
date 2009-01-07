class InventoryImport::User < ActiveRecord::Base

  has_many :geraeteparks_users
end