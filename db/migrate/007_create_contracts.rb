class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.belongs_to :user
      t.integer :status_const, :default => Contract::NEW # TODO create index 

      t.timestamps
    end
  end

  def self.down
    drop_table :contracts
  end
end
