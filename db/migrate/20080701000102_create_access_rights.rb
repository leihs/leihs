class CreateAccessRights < ActiveRecord::Migration
  def self.up
    create_table :access_rights do |t| # , :id => false ??
      t.belongs_to :role
      t.belongs_to :user
      t.belongs_to :inventory_pool
      t.integer :level, :default => AccessRight::CUSTOMER
      t.timestamps
    end

    add_index(:access_rights, [:user_id, :inventory_pool_id], :unique => true)
    foreign_key :access_rights, :role_id, :roles
    foreign_key :access_rights, :user_id, :users
    foreign_key :access_rights, :inventory_pool_id, :inventory_pools

  end

  def self.down
    drop_table :access_rights
  end
  
end
