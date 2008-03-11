class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :inventory_code
      t.belongs_to :type

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
