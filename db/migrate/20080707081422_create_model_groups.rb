class CreateModelGroups < ActiveRecord::Migration
  def self.up
    create_table :model_groups do |t|
      t.string :type # STI (single table inheritance)
      t.string :name      
      t.timestamps
    end


    create_table :inventory_pools_model_groups, :id => false do |t|
      t.belongs_to :inventory_pool
      t.belongs_to :model_group
    end
    foreign_key :inventory_pools_model_groups, :inventory_pool_id, :inventory_pools
    foreign_key :inventory_pools_model_groups, :model_group_id, :model_groups


    create_table :model_links do |t|
      t.belongs_to :model_group
      t.belongs_to :model
      t.integer :quantity, :default => 1 # TODO 12** quantity is required for Template, but not for Category. refactor to Template validation
    end
    foreign_key :model_links, :model_group_id, :model_groups
    foreign_key :model_links, :model_id, :models

    create_table :model_groups_parents, :id => false do |t|
      t.belongs_to :model_group
      t.belongs_to :parent
      t.string  :label
    end
    foreign_key :model_groups_parents, :model_group_id, :model_groups
    foreign_key :model_groups_parents, :parent_id, :model_groups
    
  end

  def self.down
    drop_table :model_groups
    drop_table :model_links
    drop_table :model_groups_parents
  end
end
