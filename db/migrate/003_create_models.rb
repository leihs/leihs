class CreateModels < ActiveRecord::Migration
  def self.up
    create_table :models do |t|
      t.string :name
      t.string :manufacturer
      t.integer :maintenance_period, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :models
  end
end
