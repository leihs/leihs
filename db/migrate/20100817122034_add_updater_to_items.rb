class AddUpdaterToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :updater_id, :integer
  end

  def self.down
    remove_column :items, :updater_id
  end
end
