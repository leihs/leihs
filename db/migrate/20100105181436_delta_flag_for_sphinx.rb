class DeltaFlagForSphinx < ActiveRecord::Migration
  def self.up
    add_column(:model_groups,     :delta, :boolean, :default => true)
    add_column(:contracts,        :delta, :boolean, :default => true)
    add_column(:inventory_pools,  :delta, :boolean, :default => true)
    add_column(:items,            :delta,:boolean, :default => true)
    add_column(:locations,        :delta, :boolean, :default => true)
    add_column(:models,           :delta, :boolean, :default => true)
    add_column(:options,          :delta, :boolean, :default => true)
    add_column(:orders,           :delta, :boolean, :default => true)
    add_column(:backup_orders,    :delta, :boolean, :default => true)
    add_column(:roles,            :delta, :boolean, :default => true)
    add_column(:users,            :delta, :boolean, :default => true)
  end

  def self.down
    remove_column(:model_groups,    :delta)
    remove_column(:contracts,       :delta)
    remove_column(:inventory_pools, :delta)
    remove_column(:items,           :delta)
    remove_column(:locations,       :delta)
    remove_column(:models,          :delta)
    remove_column(:options,         :delta)
    remove_column(:orders,          :delta)
    remove_column(:backup_orders,   :delta)
    remove_column(:roles,           :delta)
    remove_column(:users,           :delta)
  end
end
