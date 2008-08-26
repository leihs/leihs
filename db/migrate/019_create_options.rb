class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.belongs_to :contract
      t.integer :quantity
      t.string :barcode
      t.string :name
      t.date :returned_date
      t.timestamps
    end
    
    create_table :option_maps do |t|
      t.string :barcode
      t.string :text
    end
  
  end
  
  def self.down
    drop_table :options
  end
end
