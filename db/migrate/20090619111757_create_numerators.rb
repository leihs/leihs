class CreateNumerators < ActiveRecord::Migration
  def self.up
    create_table :numerators do |t|
      t.integer :item
    end
  end

  def self.down
    drop_table :numerators
  end
end
