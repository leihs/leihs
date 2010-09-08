class CreateAvailablityChanges < ActiveRecord::Migration
  def self.up
    create_table :availability_changes do |t|
      t.date       :date
      t.belongs_to :inventory_pool
      t.belongs_to :model

      t.timestamps
    end

    # TODO unique [date, inventory_pool_id, model_id] 

    create_table :availability_quantities do |t|
      t.belongs_to :availability_change
      t.belongs_to :group
      t.integer    :in_quantity, :default => 0
      t.integer    :out_quantity, :default => 0
      t.text       :documents # serialize
    end

    Availability2::Change.recompute_all
    
  end

  def self.down
    drop_table :availability_changes
    drop_table :availability_quantities
  end
end

