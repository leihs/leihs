class CreateAccessRights < ActiveRecord::Migration
  def self.up
    create_table :access_rights do |t| # , :id => false ??
      t.belongs_to :role
      t.belongs_to :user
      t.belongs_to :inventory_pool

      t.timestamps
    end

    add_index(:access_rights, :role_id)
    add_index(:access_rights, :user_id)
    add_index(:access_rights, :inventory_pool_id)
  
  end

  def self.down
    drop_table :access_rights
  end
end
