class CreateOrderLines < ActiveRecord::Migration
  def self.up
    create_table :order_lines do |t|
      t.belongs_to :model
      t.belongs_to :order
      t.integer :quantity
      t.date :start_date #, :default => DateTime.now  #Date.today #"CURDATE()"
      t.date :end_date #, :default => DateTime.now  #Date.today #"CURDATE()"
      t.boolean :contract_generated, :default => false

      t.timestamps
    end

    # TODO acts_as_backupable
    create_table :backup_order_lines do |t|
      t.belongs_to :model
      t.belongs_to :order
      t.integer :quantity
      t.date :start_date #, :default => DateTime.now  #Date.today #"CURDATE()"
      t.date :end_date #, :default => DateTime.now  #Date.today #"CURDATE()"
      t.boolean :contract_generated

      t.timestamps
    end
  
  end

  def self.down
    drop_table :order_lines
    
    drop_table :backup_order_lines # TODO acts_as_backupable
  end
end
