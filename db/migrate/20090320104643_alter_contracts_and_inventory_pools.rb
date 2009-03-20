class AlterContractsAndInventoryPools < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.text :note, :null => true
    end

    change_table :inventory_pools do |t|
      t.text :default_contract_note, :null => true
    end
  end


  def self.down
    change_table :contracts do |t|
      t.remove :note
    end

    change_table :inventory_pools do |t|
      t.remove :default_contract_note
    end
  end
end
