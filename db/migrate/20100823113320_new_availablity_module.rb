class NewAvailablityModule < ActiveRecord::Migration
  def self.up
    create_table :availability_changes do |t|
      t.date       :date
      t.belongs_to :inventory_pool
      t.belongs_to :model

      t.timestamps
    end

    change_table :availability_changes do |t|
      t.index [:date, :inventory_pool_id, :model_id], :unique => true, :name => "index_on_date_and_inventory_pool_and_model"
      t.index [:inventory_pool_id, :model_id], :name => "index_on_inventory_pool_and_model"
    end

    ######

    create_table :availability_quantities do |t|
      t.belongs_to :change
      t.belongs_to :group
      t.integer    :in_quantity, :default => 0
      t.integer    :out_quantity, :default => 0
      t.text       :out_document_lines # serialize #tmp#5
    end

    change_table :availability_quantities do |t|
      t.index [:change_id, :group_id], :unique => true
      t.index :in_quantity
    end

    ######

    remove_column :contract_lines, :cached_available
    remove_column :order_lines, :cached_available

    ######

    Availability::Change.recompute_all
    
  end

  def self.down
    drop_table :availability_changes
    drop_table :availability_quantities

    add_column :contract_lines, :cached_available, :boolean, :null => true, :default => nil
    add_column :order_lines, :cached_available, :boolean, :null => true, :default => nil
  end
end

