class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.belongs_to :user
      t.belongs_to :inventory_pool
      t.integer :status_const, :default => Contract::NEW # TODO create index 
      t.string :purpose # TODO implement
      t.timestamps
    end
  end

  def self.down
    drop_table :contracts
  end
end
