class OptimizeIndexes < ActiveRecord::Migration
  def self.up
    change_table :access_rights do |t|
      t.index         :suspended_until
      t.index         :deleted_at
      t.remove_index  :user_id
    end

    change_table :accessories_inventory_pools do |t|
      t.remove_index  :accessory_id
    end

    # TODO ??
    # remove_foreign_key_and_add_index :attachments, :model_id
    
    change_table :backup_order_lines do |t|
      t.index         :order_id
    end

    change_table :comments do |t|
      t.index         [:commentable_type, :commentable_id]
    end

    change_table :contract_lines do |t|
      t.index         :start_date
      t.index         :end_date
      t.index         :returned_date
      t.index         :option_id
      t.index         :type
    end

    change_table :contracts do |t|
      t.index         :delta
    end

    change_table :groups do |t|
      t.index         :inventory_pool_id
    end
    
    change_table :groups_users do |t|
      t.index         :user_id
      t.index         :group_id
    end
    
    change_table :histories do |t|
      t.index         [:target_type, :target_id]
      t.index         :type_const
    end

    change_table :inventory_pools do |t|
      t.index         :delta
    end

    change_table :items do |t|
      t.index         :inventory_pool_id
      t.index         :retired
      t.index         :delta
    end

    change_table :locations do |t|
      t.index         :building_id
      t.index         :delta
    end

    change_table :model_groups do |t|
      t.index         :delta
    end

    change_table :models do |t|
      t.index         :delta
    end
  
    change_table :options do |t|
      t.index         :delta
    end

    change_table :order_lines do |t|
      t.index         :start_date
      t.index         :end_date
    end

    change_table :orders do |t|
      t.index         :delta
    end

    change_table :roles do |t|
      t.index         :delta
    end

    change_table :users do |t|
      t.index         :delta
    end

  end

  def self.down
  end
end
