class CreateWorkdays < ActiveRecord::Migration
  def self.up
    create_table :workdays do |t|
      t.belongs_to :inventory_pool
      t.boolean :monday, :default => true
      t.boolean :tuesday, :default => true
      t.boolean :wednesday, :default => true
      t.boolean :thursday, :default => true
      t.boolean :friday, :default => true
      t.boolean :saturday, :default => false
      t.boolean :sunday, :default => false
    end

    foreign_key :workdays, :inventory_pool_id, :inventory_pools

  end

  def self.down
    drop_table :workdays
  end
end
