class RemoveLocationMain < ActiveRecord::Migration
  def self.up
    change_table :locations do |t|
      t.remove :is_main
    end

  end

  def self.down
    change_table :locations do |t|
      t.boolean :is_main, :default => false
    end
  end
end
