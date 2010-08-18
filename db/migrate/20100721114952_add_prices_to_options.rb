class AddPricesToOptions < ActiveRecord::Migration
  def self.up
    add_column :options, :price, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :options, :price
  end
end
