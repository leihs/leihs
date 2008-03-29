class CreateAccessRights < ActiveRecord::Migration
  def self.up
    create_table :access_rights do |t|
      t.belongs_to :role
      t.belongs_to :permission
      t.belongs_to :inventory_pool

      t.timestamps
    end
  end

  def self.down
    drop_table :access_rights
  end
end
