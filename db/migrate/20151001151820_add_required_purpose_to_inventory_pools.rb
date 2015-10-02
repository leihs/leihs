class AddRequiredPurposeToInventoryPools < ActiveRecord::Migration
  def change

    change_table :inventory_pools do |t|
      t.boolean :required_purpose, default: true
    end

  end
end
