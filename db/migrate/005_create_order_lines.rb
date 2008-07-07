class CreateOrderLines < ActiveRecord::Migration
  def self.up
    create_table :order_lines do |t|
      t.belongs_to :model
      t.belongs_to :line_group, :null => true
      t.belongs_to :order
      t.belongs_to :inventory_pool # OPTIMIZE redundant with order.inventory_pool
      t.integer :quantity, :default => 1
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    # TODO acts_as_backupable
    create_table :backup_order_lines do |t|
      t.belongs_to :model
      t.belongs_to :line_group, :null => true
      t.belongs_to :order
      t.belongs_to :inventory_pool # OPTIMIZE redundant with order.inventory_pool
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
