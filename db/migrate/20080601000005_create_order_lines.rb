class CreateOrderLines < ActiveRecord::Migration
  def self.up
    create_table :order_lines do |t|
      t.belongs_to :model
      t.belongs_to :order
      t.belongs_to :inventory_pool
      t.integer :quantity, :default => 1
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
    foreign_key :order_lines, :model_id, :models
    foreign_key :order_lines, :order_id, :orders
    foreign_key :order_lines, :inventory_pool_id, :inventory_pools


    # TODO acts_as_backupable
    create_table :backup_order_lines do |t|
      t.belongs_to :model
      t.belongs_to :order
      t.belongs_to :inventory_pool
      t.integer :quantity
      t.date :start_date
      t.date :end_date
      
      t.timestamps
    end
  
  end

  def self.down
    drop_table :order_lines
    
    drop_table :backup_order_lines # TODO acts_as_backupable
  end
end
