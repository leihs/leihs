class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.belongs_to :model
      t.string :key
      t.string :value

      t.timestamps
    end

    foreign_key :properties, :model_id, :models
  
  end

  def self.down
    drop_table :properties
  end
end
