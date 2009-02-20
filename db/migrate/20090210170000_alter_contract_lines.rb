class AlterContractLines < ActiveRecord::Migration
  def self.up

    drop_table :options

    rename_table :option_maps, :options
    rename_column :options, :barcode, :inventory_code
    rename_column :options, :text, :name

    change_table :contract_lines do |t|
      t.belongs_to :option, :null => true
      t.string :type, :null => false, :default => 'ItemLine'   # STI (single table inheritance)
    end
    foreign_key :contract_lines, :option_id, :options
        
  end

  def self.down
    remove_foreign_key :contract_lines, :option_id
    change_table :contract_lines do |t|
      t.remove :option_id
      t.remove :type
    end

    rename_column :options, :inventory_code, :barcode
    rename_column :options, :name, :text
    rename_table :options, :option_maps
  
    create_table :options do |t|
      t.belongs_to :contract
      t.integer :quantity
      t.string :barcode
      t.string :name
      t.date :returned_date
    end
    foreign_key :options, :contract_id, :contracts

  end
end
