class DropForeignKeyConstraints < ActiveRecord::Migration
  
  def self.up
    remove_foreign_key_and_add_index :users, :authentication_system_id
    remove_foreign_key_and_add_index :models_compatibles, :model_id
    remove_foreign_key_and_add_index :models_compatibles, :compatible_id
    remove_foreign_key_and_add_index :properties, :model_id
    remove_foreign_key_and_add_index :comments, :user_id
    remove_foreign_key_and_add_index :histories, :user_id
    remove_foreign_key_and_add_index :locations, :inventory_pool_id
    remove_foreign_key_and_add_index :items, :model_id
    remove_foreign_key_and_add_index :items, :location_id
    remove_foreign_key_and_add_index :items, :owner_id
    remove_foreign_key_and_add_index :items, :parent_id
    remove_foreign_key_and_add_index :orders, :user_id
    remove_foreign_key_and_add_index :orders, :inventory_pool_id
    remove_foreign_key_and_add_index :backup_orders, :order_id
    remove_foreign_key_and_add_index :backup_orders, :user_id
    remove_foreign_key_and_add_index :backup_orders, :inventory_pool_id
    remove_foreign_key_and_add_index :order_lines, :model_id
    remove_foreign_key_and_add_index :order_lines, :order_id
    remove_foreign_key_and_add_index :order_lines, :inventory_pool_id
    remove_foreign_key_and_add_index :contracts, :user_id
    remove_foreign_key_and_add_index :contracts, :inventory_pool_id
    # This breaks on our DB - quick fix is to not do it.
    # 
    # It's an error in MySQL. The real fix would be to use an explicit
    #      alter table x drop foreign key y
    #
    #
    # statement instead of going through AR, AND USING THE CONSTRAINT NAME as y, not the foreign key name
    # (how braindead is that?).
    #
    # The error in question is:
    #   Mysql::Error: Error on rename of './rails_leihs2_dev/contract_lines' to './rails_leihs2_dev/#sql2-1405-2cc'
    #
    # The bug is partially described here:
    #   http://bugs.mysql.com/bug.php?id=14347
    #
    #remove_foreign_key_and_add_index :contract_lines, :contract_id
    #remove_foreign_key_and_add_index :contract_lines, :item_id
    #remove_foreign_key_and_add_index :contract_lines, :model_id
    #remove_foreign_key_and_add_index :contract_lines, :location_id
    remove_foreign_key_and_add_index :accessories, :model_id
    remove_foreign_key_and_add_index :accessories_inventory_pools, :accessory_id
    remove_foreign_key_and_add_index :accessories_inventory_pools, :inventory_pool_id
    remove_foreign_key_and_add_index :options, :inventory_pool_id, "fk_option_maps_inventory_pool_id"
    remove_foreign_key_and_add_index :access_rights, :role_id
    remove_foreign_key_and_add_index :access_rights, :user_id
    remove_foreign_key_and_add_index :access_rights, :inventory_pool_id
    remove_foreign_key_and_add_index :inventory_pools_model_groups, :inventory_pool_id
    remove_foreign_key_and_add_index :inventory_pools_model_groups, :model_group_id
    remove_foreign_key_and_add_index :model_links, :model_group_id
    remove_foreign_key_and_add_index :model_links, :model_id
    remove_foreign_key_and_add_index :model_groups_parents, :model_group_id
    remove_foreign_key_and_add_index :model_groups_parents, :parent_id
    remove_foreign_key_and_add_index :images, :model_id
    remove_foreign_key_and_add_index :notifications, :user_id
    remove_foreign_key_and_add_index :workdays, :inventory_pool_id
    remove_foreign_key_and_add_index :holidays, :inventory_pool_id
    #remove_foreign_key_and_add_index :contract_lines, :option_id
  end

  def self.down
    remove_index_and_add_foreign_key :users, :authentication_system_id, :authentication_systems
    remove_index_and_add_foreign_key :models_compatibles, :model_id, :models
    remove_index_and_add_foreign_key :models_compatibles, :compatible_id, :models
    remove_index_and_add_foreign_key :properties, :model_id, :models
    remove_index_and_add_foreign_key :comments, :user_id, :users
    remove_index_and_add_foreign_key :histories, :user_id, :users
    remove_index_and_add_foreign_key :locations, :inventory_pool_id, :inventory_pools
    remove_index_and_add_foreign_key :items, :model_id, :models
    remove_index_and_add_foreign_key :items, :location_id, :locations
    remove_index_and_add_foreign_key :items, :owner_id, :inventory_pools
    remove_index_and_add_foreign_key :items, :parent_id, :items
    remove_index_and_add_foreign_key :orders, :user_id, :users
    remove_index_and_add_foreign_key :orders, :inventory_pool_id, :inventory_pools
    remove_index_and_add_foreign_key :backup_orders, :order_id, :orders
    remove_index_and_add_foreign_key :backup_orders, :user_id, :users
    remove_index_and_add_foreign_key :backup_orders, :inventory_pool_id, :inventory_pools
    remove_index_and_add_foreign_key :order_lines, :model_id, :models
    remove_index_and_add_foreign_key :order_lines, :order_id, :orders
    remove_index_and_add_foreign_key :order_lines, :inventory_pool_id, :inventory_pools
    remove_index_and_add_foreign_key :contracts, :user_id, :users
    remove_index_and_add_foreign_key :contracts, :inventory_pool_id, :inventory_pools
    #remove_index_and_add_foreign_key :contract_lines, :contract_id, :contracts
    #remove_index_and_add_foreign_key :contract_lines, :item_id, :items
    #remove_index_and_add_foreign_key :contract_lines, :model_id, :models
    #remove_index_and_add_foreign_key :contract_lines, :location_id, :locations
    remove_index_and_add_foreign_key :accessories, :model_id, :models
    remove_index_and_add_foreign_key :accessories_inventory_pools, :accessory_id, :accessories
    remove_index_and_add_foreign_key :accessories_inventory_pools, :inventory_pool_id, :inventory_pools
    remove_index_and_add_foreign_key :options, :inventory_pool_id, :inventory_pools, "fk_option_maps_inventory_pool_id"
    remove_index_and_add_foreign_key :access_rights, :role_id, :roles
    remove_index_and_add_foreign_key :access_rights, :user_id, :users
    remove_index_and_add_foreign_key :access_rights, :inventory_pool_id, :inventory_pools
    remove_index_and_add_foreign_key :inventory_pools_model_groups, :inventory_pool_id, :inventory_pools
    remove_index_and_add_foreign_key :inventory_pools_model_groups, :model_group_id, :model_groups
    remove_index_and_add_foreign_key :model_links, :model_group_id, :model_groups
    remove_index_and_add_foreign_key :model_links, :model_id, :models
    remove_index_and_add_foreign_key :model_groups_parents, :model_group_id, :model_groups
    remove_index_and_add_foreign_key :model_groups_parents, :parent_id, :model_groups
    remove_index_and_add_foreign_key :images, :model_id, :models
    remove_index_and_add_foreign_key :notifications, :user_id, :users
    remove_index_and_add_foreign_key :workdays, :inventory_pool_id, :inventory_pools
    remove_index_and_add_foreign_key :holidays, :inventory_pool_id, :inventory_pools
    #remove_index_and_add_foreign_key :contract_lines, :option_id, :options
  end
end
