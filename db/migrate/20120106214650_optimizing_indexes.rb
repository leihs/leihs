class OptimizingIndexes < ActiveRecord::Migration
  def change

    change_table :access_rights do |t|
      t.remove_index [:user_id, :inventory_pool_id]
      t.index [:user_id, :inventory_pool_id, :deleted_at], :name => :index_on_user_id_and_inventory_pool_id_and_deleted_at
    end

    table_name = :contract_lines
    existing_indexes = indexes(table_name).map(&:name)
    [:contract_lines_contract_id, :contract_lines_option_id, :contract_lines_model_id, :contract_lines_item_id].each do |index_name|
      remove_index table_name, :name => index_name if existing_indexes.include? index_name.to_s 
    end

    change_table :contract_lines do |t|
      t.remove_index :returned_date 
      t.remove_index :type 
      t.index [:returned_date, :contract_id]
      t.index [:type, :contract_id]
    end

    table_name = :contracts
    existing_indexes = indexes(table_name).map(&:name)
    [:fk_contracts_user_id, :fk_contracts_inventory_pool_id].each do |index_name|
      remove_index table_name, :name => index_name if existing_indexes.include? index_name.to_s 
    end

    change_table :holidays do |t|
      t.index [:start_date, :end_date]
    end

    change_table :inventory_pools do |t|
      t.index :name, :unique => true
    end

    change_table :items do |t|
      t.remove_index :parent_id
      t.remove_index :model_id
      t.index [:parent_id, :retired]
      t.index [:model_id, :retired, :inventory_pool_id]
    end

    change_table :languages do |t|
      t.index :name, :unique => true
      t.index [:active, :default]
    end

    change_table :model_group_links do |t|
      t.remove_index :descendant_id
      t.index [:descendant_id, :ancestor_id, :direct], :name => :index_on_descendant_id_and_ancestor_id_and_direct
    end

    change_table :model_groups do |t|
      t.index :type
    end

    change_table :model_links do |t|
      t.remove_index :model_id
      t.remove_index :model_group_id
      t.index [:model_id, :model_group_id]
      t.index [:model_group_id, :model_id]
    end

    change_table :orders do |t|
      t.remove_index :user_id
      t.index [:user_id, :status_const]
      t.index :created_at
    end

    change_table :order_lines do |t|
      t.index :created_at
    end

  end
end
