class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :inventory_code
      t.belongs_to :model
      t.belongs_to :inventory_pool

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
