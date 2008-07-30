class CreateAccessories < ActiveRecord::Migration
  def self.up
    create_table :accessories do |t|
      t.belongs_to :model
      t.string :name
    end
  end

  def self.down
    drop_table :accessories
  end
end
