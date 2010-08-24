class CreateAvailablityChanges < ActiveRecord::Migration
  def self.up
    create_table :availability_changes do |t|
      t.date       :date
      t.belongs_to :inventory_pool
      t.belongs_to :model

      t.timestamps
    end

    create_table :available_quantities do |t|
      t.integer    :status_const         # available, borrowable, unborrowable - see model!
      t.belongs_to :availability_change
      t.belongs_to :group
      t.integer    :quantity
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

