class CreateInventoryPools < ActiveRecord::Migration
  def self.up
    create_table :inventory_pools do |t|
      t.string :name
      t.text   :description
      t.string :contact_details
      t.string :contract_description
      t.string :contract_url
      t.string :logo_url
    end
  end

  def self.down
    drop_table :inventory_pools
  end
end
