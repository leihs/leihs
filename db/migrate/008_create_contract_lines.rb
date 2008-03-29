class CreateContractLines < ActiveRecord::Migration
  def self.up
    create_table :contract_lines do |t|
      t.belongs_to :contract
      t.belongs_to :item
      t.integer :quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contract_lines
  end
end
