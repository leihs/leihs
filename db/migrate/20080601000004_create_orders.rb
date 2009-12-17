class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.belongs_to :user
      t.belongs_to :inventory_pool
      t.integer :status_const, :default => Order::UNSUBMITTED 
      t.string :purpose
      t.timestamps
    end
    add_index(:orders, :status_const)
    foreign_key :orders, :user_id, :users
    foreign_key :orders, :inventory_pool_id, :inventory_pools


    # TODO acts_as_backupable
    create_table :backup_orders do |t|
      t.belongs_to :order   # reference to orginal
      t.belongs_to :user
      t.belongs_to :inventory_pool
      t.integer :status_const, :default => Order::UNSUBMITTED 
      t.string :purpose
      t.timestamps
    end
    add_index(:backup_orders, :status_const)
    foreign_key :backup_orders, :order_id, :orders
    foreign_key :backup_orders, :user_id, :users
    foreign_key :backup_orders, :inventory_pool_id, :inventory_pools
          
  end

  def self.down
    drop_table :orders

    drop_table :backup_orders # TODO acts_as_backupable
  end
end
