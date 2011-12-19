class CreatePartitionsDropAvailability < ActiveRecord::Migration

  class AvailabilityChange < ActiveRecord::Base
    belongs_to :inventory_pool
    belongs_to :model
    has_many :availability_quantities, :foreign_key => "change_id"
  end
  class AvailabilityQuantity < ActiveRecord::Base
  end

  def self.up
    create_table :partitions do |t|
      t.belongs_to :model
      t.belongs_to :inventory_pool
      t.belongs_to :group, :null => true
      t.integer :quantity
    end
    change_table :partitions do |t|
      t.index [:model_id, :inventory_pool_id, :group_id], :unique => true
    end

    AvailabilityChange.all(:group => "model_id, inventory_pool_id").each do |change|
      partitions = {}
      change.availability_quantities.each do |q|
        v = q.in_quantity + q.out_quantity
        partitions[q.group_id] = v if q.group_id != Group::GENERAL_GROUP_ID and v > 0
      end
      change.model.partitions.in(change.inventory_pool).set(partitions) unless partitions.blank?
    end

    drop_table :availability_quantities
    drop_table :availability_changes
  end

  def self.down
    drop_table :partitions
  end
end
