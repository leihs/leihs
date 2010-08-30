class CreateAvailablityChanges < ActiveRecord::Migration
  def self.up
    create_table :availability_changes do |t|
      t.date       :date
      t.belongs_to :inventory_pool
      t.belongs_to :model

      t.timestamps
    end

    # TODO unique [date, inventory_pool_id, model_id] 

    create_table :available_quantities do |t|
      t.belongs_to :availability_change
      t.belongs_to :group
      t.integer    :available_quantity, :default => 0
      t.integer    :unavailable_quantity, :default => 0
      t.text       :documents # serialize
    end

    # TODO: Availability migration
    # InventoryPool.all.each do |ip|
    #   ip.models.each do |m|
    #     n_items = m.items.scoped_by_inventory_pool_id(ip).count
    #     AvailabilityChange.transaction do
    #       # migrate Availabilites to new schema
    #     end
    #   end
    # end
  end

  def self.down
    drop_table :availability_changes
    drop_table :available_quantities
  end
end

